import * as functions from 'firebase-functions';
import * as logger from 'firebase-functions/logger';
import * as admin from 'firebase-admin';
import Stripe = require('stripe');
import { validateOrderInput } from '../orders/validation';
import { checkIdempotency } from '../orders/orderRepository';
import { buildOrderTotals, resolveUnitPrice, StoreDeliveryConfig } from '../orders/pricing';
import { OrderItem } from '../orders/types';

const db = admin.firestore();

function getStripe(): Stripe.Stripe {
  const key = process.env.STRIPE_SECRET_KEY;
  if (!key) {
    throw new functions.https.HttpsError('internal', 'Stripe is not configured.');
  }
  return new Stripe(key, { apiVersion: '2026-04-22.dahlia' });
}

/**
 * Callable Function: createPaymentIntent
 *
 * Validates cart server-side (prices, stock, store status) and creates a
 * Stripe PaymentIntent with the authoritative total. Returns clientSecret
 * to the Flutter client for PaymentSheet initialisation.
 *
 * The Firestore order is NOT created here — it is created by stripeWebhook
 * after payment_intent.succeeded fires (no ghost orders).
 */
export const createPaymentIntent = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'You must be signed in to pay.');
  }

  const uid = request.auth.uid;
  logger.info('createPaymentIntent called', { uid });

  try {
    // ── 1: Validate input (storeId, items, idempotencyKey) ────────────────
    const input = validateOrderInput({
      ...request.data,
      paymentMethod: 'card', // PaymentSheet handles method selection
    });

    // ── 2: Idempotency fast-path ──────────────────────────────────────────
    if (input.idempotencyKey) {
      const existingOrderId = await checkIdempotency(input.idempotencyKey, uid);
      if (existingOrderId) {
        logger.info('Duplicate payment attempt — order already exists', { uid, existingOrderId });
        throw new functions.https.HttpsError('already-exists', 'This order has already been paid.');
      }
    }

    // ── 3: Validate store ─────────────────────────────────────────────────
    const storeSnap = await db.collection('stores').doc(input.storeId).get();
    if (!storeSnap.exists) throw new functions.https.HttpsError('not-found', 'Store not found.');
    const storeData = storeSnap.data()!;
    if (!storeData.isActive) throw new functions.https.HttpsError('failed-precondition', 'This store is currently inactive.');
    if (!storeData.isApproved) throw new functions.https.HttpsError('failed-precondition', 'This store is not yet approved.');
    if (!storeData.isOpen) throw new functions.https.HttpsError('failed-precondition', 'This store is currently closed.');

    // ── 4: Validate products & compute authoritative total ────────────────
    const productRefs = input.items.map((item) => db.collection('products').doc(item.productId));
    const productSnaps = await db.getAll(...productRefs);

    const orderItems: OrderItem[] = [];
    for (let i = 0; i < input.items.length; i++) {
      const reqItem = input.items[i];
      const snap = productSnaps[i];
      if (!snap.exists) throw new functions.https.HttpsError('not-found', `Product ${reqItem.productId} not found.`);
      const product = snap.data()!;
      if (product.storeId !== input.storeId) throw new functions.https.HttpsError('invalid-argument', `Product "${product.name}" does not belong to this store.`);
      if (product.isAvailable === false) throw new functions.https.HttpsError('failed-precondition', `"${product.name}" is currently unavailable.`);
      const stock: number = product.quantity ?? 0;
      if (stock < reqItem.quantity) throw new functions.https.HttpsError('failed-precondition', `Insufficient stock for "${product.name}". Available: ${stock}.`);

      orderItems.push({
        productId: reqItem.productId,
        storeId: input.storeId,
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

    if (totals.subtotal < (storeConfig.minimumOrderAmount ?? 0)) {
      throw new functions.https.HttpsError('failed-precondition', `Minimum order amount is €${storeConfig.minimumOrderAmount}.`);
    }

    // ── 5: Create Stripe PaymentIntent with metadata for webhook ──────────
    const amountInCents = Math.round(totals.total * 100);
    const stripe = getStripe();
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountInCents,
      currency: 'eur',
      automatic_payment_methods: { enabled: true },
      metadata: {
        userId: uid,
        storeId: input.storeId,
        items: JSON.stringify(input.items),
        orderNote: input.orderNote ?? '',
        idempotencyKey: input.idempotencyKey ?? '',
        subtotal: totals.subtotal.toFixed(2),
        deliveryFee: totals.deliveryFee.toFixed(2),
        total: totals.total.toFixed(2),
      },
    });

    logger.info('PaymentIntent created', { paymentIntentId: paymentIntent.id, uid, amountInCents });
    return { clientSecret: paymentIntent.client_secret! };

  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    logger.error('createPaymentIntent unexpected error', {
      uid,
      error: error instanceof Error ? error.message : 'Unknown',
    });
    throw new functions.https.HttpsError('internal', 'Failed to create payment. Please try again.');
  }
});
