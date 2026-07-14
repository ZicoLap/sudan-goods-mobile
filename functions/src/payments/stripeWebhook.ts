import * as functions from 'firebase-functions';
import * as logger from 'firebase-functions/logger';
import * as admin from 'firebase-admin';
import Stripe = require('stripe');
import { resolveUnitPrice } from '../orders/pricing';
import { cleanupCart, idempotencyDocId } from '../orders/orderRepository';
import { fetchOrderUserProfile } from '../services/userService';
import { OrderItem } from '../orders/types';

const db = admin.firestore();

// Fix #13: Module-level lazy singletons — avoids re-instantiating on every invocation.
let _stripe: Stripe.Stripe | null = null;
function getStripe(): Stripe.Stripe {
  if (!_stripe) {
    const key = process.env.STRIPE_SECRET_KEY;
    if (!key) throw new Error('STRIPE_SECRET_KEY not configured');
    _stripe = new Stripe(key, { apiVersion: '2026-04-22.dahlia' });
  }
  return _stripe;
}

function getWebhookSecret(): string {
  const secret = process.env.STRIPE_WEBHOOK_SECRET;
  if (!secret) throw new Error('STRIPE_WEBHOOK_SECRET not configured');
  return secret;
}

/**
 * HTTP Function: stripeWebhook
 *
 * Handles Stripe webhook events. Must be an HTTP function (not callable)
 * so that req.rawBody is available for signature verification.
 *
 * payment_intent.succeeded  → creates Firestore order + decrements stock
 * payment_intent.payment_failed → logs only, no Firestore writes
 */
export const stripeWebhook = functions.https.onRequest(async (req, res) => {
  // Fix #15: Wrap entire handler so bare errors (e.g. missing env vars) return 500
  // instead of leaking stack traces, and so Stripe retries on infrastructure failures.
  try {
    // ── 1: Verify signature ─────────────────────────────────────────────────
    const sig = req.headers['stripe-signature'];
    if (!sig) {
      res.status(400).send('Missing stripe-signature header');
      return;
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let event: any;
    try {
      const stripe = getStripe();
      event = stripe.webhooks.constructEvent(
        (req as any).rawBody,
        sig,
        getWebhookSecret()
      ) as any;
    } catch (err) {
      logger.warn('Webhook signature verification failed', {
        error: err instanceof Error ? err.message : 'Unknown',
      });
      res.status(400).send('Webhook signature verification failed');
      return;
    }

    logger.info('Stripe webhook received', { type: event.type, id: event.id });

    // ── 2: Route by event type ──────────────────────────────────────────────
    if (event.type === 'payment_intent.succeeded') {
      // Fix #1: await before sending 200 so Stripe retries if we throw.
      await handlePaymentSucceeded(event.data.object as Record<string, any>);
    } else if (event.type === 'payment_intent.payment_failed') {
      // Fix #11: Persist failure record so the app can surface it to the user.
      await handlePaymentFailed(event.data.object as Record<string, any>);
    } else {
      logger.info('Unhandled event type', { type: event.type });
    }

    // Fix #1: 200 only reaches Stripe after all work succeeds.
    res.status(200).send({ received: true });
  } catch (err) {
    // Fix #15: Infrastructure errors (missing keys, etc.) return 500 so Stripe retries.
    logger.error('Unhandled error in stripeWebhook', {
      error: err instanceof Error ? err.message : 'Unknown',
    });
    res.status(500).send('Internal error');
  }
});

async function handlePaymentSucceeded(pi: Record<string, any>): Promise<void> {
  const meta = pi.metadata ?? {};
  const requestId = `webhook_${pi.id}`;

  logger.info('payment_intent.succeeded received', {
    requestId,
    paymentIntentId: pi.id,
    amount: pi.amount,
  });

  // ── Parse metadata ────────────────────────────────────────────────────────
  const uid: string = meta.userId ?? '';
  const storeId: string = meta.storeId ?? '';
  const idempotencyKey: string = meta.idempotencyKey ?? '';

  // Fix #3: Read the verified totals that were computed and stored at PaymentIntent
  // creation time. Using these avoids price drift if a store owner changes prices
  // between intent creation and webhook delivery.
  const chargedSubtotal: number = parseFloat(meta.subtotal ?? '0');
  const chargedDeliveryFee: number = parseFloat(meta.deliveryFee ?? '0');
  const chargedTotal: number = parseFloat(meta.total ?? '0');

  // Fix #9: Parse client-selected address index from metadata.
  const addressIndex: number = parseInt(meta.addressIndex ?? '0', 10) || 0;

  let rawItems: { productId: string; quantity: number }[] = [];
  try {
    rawItems = JSON.parse(meta.items ?? '[]');
  } catch {
    logger.error('Failed to parse items from PaymentIntent metadata', { requestId });
    // Fix #1: throw so the outer handler returns 500 and Stripe retries.
    throw new Error('Failed to parse items from PaymentIntent metadata');
  }

  if (!uid || !storeId || rawItems.length === 0) {
    logger.error('Missing required metadata in PaymentIntent', { requestId, meta });
    // Metadata is permanently corrupt — do not retry, log for manual recovery.
    return;
  }

  // ── Fast-path idempotency check (Fix #2 — uses deterministic doc ID, consistent with transaction write) ──
  if (idempotencyKey) {
    const idempDocId = idempotencyDocId(uid, idempotencyKey);
    const existing = await db.collection('orderRequests').doc(idempDocId).get();
    if (existing.exists) {
      logger.info('Duplicate webhook — order already created', {
        requestId,
        orderId: existing.data()!.orderId,
      });
      return;
    }
  }

  // ── Fetch user profile ────────────────────────────────────────────────────
  let userProfile: Awaited<ReturnType<typeof fetchOrderUserProfile>>;
  try {
    // Fix #9: Use the address index stored in metadata at intent creation time.
    userProfile = await fetchOrderUserProfile(uid, addressIndex);
  } catch (err) {
    logger.error('Failed to fetch user profile in webhook', { requestId, uid, error: err });
    // Fix #1: throw so Stripe retries — user profile fetch may be a transient failure.
    throw err;
  }

  // ── Firestore transaction: idempotency guard → validate → decrement stock → create order ──
  // Fix #1: Do NOT catch here — let errors propagate so the outer handler returns 500
  // and Stripe retries the webhook delivery.
  await db.runTransaction(async (tx) => {
    // Note (#2): Firestore transactions cannot read by query, only by DocumentReference.
    // The fast-path pre-check above handles duplicate webhook deliveries.
    // The idempotency write below (tx.set on orderRequests) is the commit-time guard:
    // if two transactions race, only one commits; the other retries and the pre-check exits.

    const storeRef = db.collection('stores').doc(storeId);
    const storeSnap = await tx.get(storeRef);
    if (!storeSnap.exists) throw new Error(`Store ${storeId} not found`);

    const productRefs = rawItems.map((item) => db.collection('products').doc(item.productId));
    const productSnaps = await tx.getAll(...productRefs);

    // Fix #4: Track which items have stock issues for fulfillment flagging.
    const orderItems: (OrderItem & { fulfillmentIssue?: string })[] = [];

    for (let i = 0; i < rawItems.length; i++) {
      const reqItem = rawItems[i];
      const snap = productSnaps[i];
      if (!snap.exists) {
        logger.warn('Product missing at webhook time (user already paid)', { requestId, productId: reqItem.productId });
        // Fix #4: Include item with fulfillment flag so merchant sees what needs resolution.
        orderItems.push({
          productId: reqItem.productId,
          storeId,
          name: reqItem.productId,
          imageUrl: null,
          price: 0,
          weight: 0,
          quantity: reqItem.quantity,
          fulfillmentIssue: 'product_not_found',
        });
        continue;
      }
      const product = snap.data()!;
      const stock: number = product.quantity ?? 0;

      // Fix #4: Flag but still include — user paid, order must be created.
      // Skip stock decrement for out-of-stock items to avoid negative stock.
      const hasStockIssue = stock < reqItem.quantity;
      if (hasStockIssue) {
        logger.warn('Stock depleted at webhook time (user already paid)', {
          requestId,
          productId: reqItem.productId,
          available: stock,
          requested: reqItem.quantity,
        });
      }

      const itemEntry: OrderItem & { fulfillmentIssue?: string } = {
        productId: reqItem.productId,
        storeId,
        name: product.name ?? '',
        imageUrl: product.images?.length > 0 ? product.images[0] : null,
        price: resolveUnitPrice(product as { price: number; discountPrice?: number | null }),
        weight: product.weight ?? 0,
        quantity: reqItem.quantity,
      };
      if (hasStockIssue) {
        itemEntry.fulfillmentIssue = 'insufficient_stock';
      }
      orderItems.push(itemEntry);

      // Fix #4: Only decrement stock if there is enough; skip decrement for depleted items.
      if (!hasStockIssue) {
        tx.update(productRefs[i], {
          quantity: admin.firestore.FieldValue.increment(-reqItem.quantity),
        });
      }
    }

    // Fix #3: Use the verified totals from metadata (what was actually charged).
    // Do NOT recompute from live Firestore — prices may have changed since payment.
    const hasFulfillmentIssues = orderItems.some((it) => it.fulfillmentIssue);

    // Write order — paid immediately; merchant confirms before status advances.
    const orderRef = db.collection('orders').doc();
    tx.set(orderRef, {
      userId: uid,
      storeId,
      items: orderItems,
      subtotal: chargedSubtotal,
      deliveryFee: chargedDeliveryFee,
      total: chargedTotal,
      status: hasFulfillmentIssues ? 'fulfillment_review' : 'pending',
      paymentStatus: 'paid',
      paymentMethod: 'card',
      paymentIntentId: pi.id,
      name: userProfile.name,
      phone: userProfile.phone,
      address: userProfile.address,
      orderNote: meta.orderNote || null,
      hasFulfillmentIssues,
      paidAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Fix #2: Write idempotency record atomically with the order using deterministic doc ID.
    if (idempotencyKey) {
      const idempDocId = idempotencyDocId(uid, idempotencyKey);
      tx.set(db.collection('orderRequests').doc(idempDocId), {
        idempotencyKey,
        userId: uid,
        orderId: orderRef.id,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    logger.info('Order created via webhook', {
      requestId,
      orderId: orderRef.id,
      uid,
      storeId,
      total: chargedTotal,
      paymentIntentId: pi.id,
      hasFulfillmentIssues,
    });
  });

  // ── Best-effort cart cleanup ──────────────────────────────────────────────
  await cleanupCart(uid, storeId, requestId);
}

// Fix #11: Persist payment failure record so the Flutter app can surface it to the user.
async function handlePaymentFailed(pi: Record<string, any>): Promise<void> {
  const uid: string = pi.metadata?.userId ?? '';
  const paymentIntentId: string = pi.id ?? '';
  const reason: string = pi.last_payment_error?.message ?? 'unknown';

  logger.info('payment_intent.payment_failed', { paymentIntentId, uid, reason });

  if (!uid || !paymentIntentId) return;

  try {
    await db.collection('paymentFailures').doc(paymentIntentId).set({
      userId: uid,
      paymentIntentId,
      reason,
      storeId: pi.metadata?.storeId ?? null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (err) {
    // Best-effort — log but don't fail the webhook response.
    logger.warn('Failed to write paymentFailures record', {
      paymentIntentId,
      error: err instanceof Error ? err.message : 'Unknown',
    });
  }
}
