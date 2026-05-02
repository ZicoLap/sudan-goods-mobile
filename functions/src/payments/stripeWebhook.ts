import * as functions from 'firebase-functions';
import * as logger from 'firebase-functions/logger';
import * as admin from 'firebase-admin';
import Stripe = require('stripe');
import { buildOrderTotals, resolveUnitPrice, StoreDeliveryConfig } from '../orders/pricing';
import { cleanupCart } from '../orders/orderRepository';
import { fetchOrderUserProfile } from '../services/userService';
import { OrderItem } from '../orders/types';

const db = admin.firestore();

function getStripe(): Stripe.Stripe {
  const key = process.env.STRIPE_SECRET_KEY;
  if (!key) throw new Error('STRIPE_SECRET_KEY not configured');
  return new Stripe(key, { apiVersion: '2026-04-22.dahlia' });
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
  // ── 1: Verify signature ───────────────────────────────────────────────────
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

  // ── 2: Route by event type ────────────────────────────────────────────────
  if (event.type === 'payment_intent.succeeded') {
    await handlePaymentSucceeded(event.data.object as Record<string, any>);
  } else if (event.type === 'payment_intent.payment_failed') {
    const pi = event.data.object as Record<string, any>;
    logger.info('payment_intent.payment_failed — no order created', {
      paymentIntentId: pi.id,
      userId: pi.metadata?.userId,
      error: pi.last_payment_error?.message,
    });
  } else {
    logger.info('Unhandled event type', { type: event.type });
  }

  // Always 200 — prevents Stripe from retrying handled events
  res.status(200).send({ received: true });
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

  let rawItems: { productId: string; quantity: number }[] = [];
  try {
    rawItems = JSON.parse(meta.items ?? '[]');
  } catch {
    logger.error('Failed to parse items from PaymentIntent metadata', { requestId });
    return;
  }

  if (!uid || !storeId || rawItems.length === 0) {
    logger.error('Missing required metadata in PaymentIntent', { requestId, meta });
    return;
  }

  // ── Idempotency guard (webhook may fire more than once) ───────────────────
  if (idempotencyKey) {
    const existing = await db
      .collection('orderRequests')
      .where('idempotencyKey', '==', idempotencyKey)
      .where('userId', '==', uid)
      .limit(1)
      .get();

    if (!existing.empty) {
      logger.info('Duplicate webhook — order already created', {
        requestId,
        orderId: existing.docs[0].data().orderId,
      });
      return;
    }
  }

  // ── Fetch user profile ────────────────────────────────────────────────────
  let userProfile: Awaited<ReturnType<typeof fetchOrderUserProfile>>;
  try {
    userProfile = await fetchOrderUserProfile(uid);
  } catch (err) {
    logger.error('Failed to fetch user profile in webhook', { requestId, uid, error: err });
    return;
  }

  // ── Firestore transaction: validate → decrement stock → create order ──────
  try {
    await db.runTransaction(async (tx) => {
      const storeRef = db.collection('stores').doc(storeId);
      const storeSnap = await tx.get(storeRef);
      if (!storeSnap.exists) throw new Error(`Store ${storeId} not found`);
      const storeData = storeSnap.data()!;

      const productRefs = rawItems.map((item) => db.collection('products').doc(item.productId));
      const productSnaps = await tx.getAll(...productRefs);

      const orderItems: OrderItem[] = [];
      for (let i = 0; i < rawItems.length; i++) {
        const reqItem = rawItems[i];
        const snap = productSnaps[i];
        if (!snap.exists) {
          logger.warn('Product missing at webhook time (user already paid)', { requestId, productId: reqItem.productId });
          continue;
        }
        const product = snap.data()!;
        const stock: number = product.quantity ?? 0;
        if (stock < reqItem.quantity) {
          logger.warn('Stock depleted at webhook time (user already paid)', { requestId, productId: reqItem.productId });
        }
        orderItems.push({
          productId: reqItem.productId,
          storeId,
          name: product.name ?? '',
          imageUrl: product.images?.length > 0 ? product.images[0] : null,
          price: resolveUnitPrice(product as { price: number; discountPrice?: number | null }),
          weight: product.weight ?? 0,
          quantity: reqItem.quantity,
        });
      }

      const storeConfig: StoreDeliveryConfig = {
        freeDeliveryOver: storeData.freeDeliveryOver ?? null,
        deliveryPricing: storeData.deliveryPricing ?? [],
        minimumOrderAmount: storeData.minimumOrderAmount ?? 0,
      };
      const totals = buildOrderTotals(orderItems, storeConfig);

      // Decrement stock atomically
      for (let i = 0; i < rawItems.length; i++) {
        if (productSnaps[i].exists) {
          tx.update(productRefs[i], {
            quantity: admin.firestore.FieldValue.increment(-rawItems[i].quantity),
          });
        }
      }

      // Write order — born confirmed + paid
      const orderRef = db.collection('orders').doc();
      tx.set(orderRef, {
        userId: uid,
        storeId,
        items: orderItems,
        subtotal: totals.subtotal,
        deliveryFee: totals.deliveryFee,
        total: totals.total,
        totalWeight: totals.totalWeight,
        status: 'confirmed',
        paymentStatus: 'paid',
        paymentMethod: 'card',
        paymentIntentId: pi.id,
        name: userProfile.name,
        phone: userProfile.phone,
        address: userProfile.address,
        orderNote: meta.orderNote || null,
        paidAt: admin.firestore.FieldValue.serverTimestamp(),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Write idempotency record
      if (idempotencyKey) {
        const idempotencyRef = db.collection('orderRequests').doc();
        tx.set(idempotencyRef, {
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
        total: totals.total,
        paymentIntentId: pi.id,
      });
    });
  } catch (err) {
    logger.error('Firestore transaction failed in webhook', {
      requestId,
      paymentIntentId: pi.id,
      error: err instanceof Error ? err.message : 'Unknown',
    });
    // Return without throwing — we already sent 200 to prevent Stripe retries.
    // Failure is logged for manual recovery.
    return;
  }

  // ── Best-effort cart cleanup ──────────────────────────────────────────────
  await cleanupCart(uid, storeId, requestId);
}
