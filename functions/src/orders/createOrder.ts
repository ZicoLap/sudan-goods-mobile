import * as functions from 'firebase-functions';
import * as logger from 'firebase-functions/logger';
import * as admin from 'firebase-admin';
import { CreateOrderRequest, CreateOrderResponse } from './types';

const db = admin.firestore();

// ── Constants ──────────────────────────────────────────────────────────────────
const MAX_QUANTITY_PER_ITEM = 50;
const MAX_TOTAL_ITEMS = 200;
const MAX_DISTINCT_PRODUCTS = 20;
const ALLOWED_PAYMENT_METHODS = ['card', 'cash_on_delivery'];

/**
 * Cloud Callable Function: createOrder
 *
 * Receives minimal input from the client, fetches authoritative product/store
 * data from Firestore, computes totals server-side, and writes the order
 * document using Admin SDK (bypasses security rules).
 *
 * All reads, stock decrements, and writes happen inside a single Firestore
 * transaction to guarantee atomicity — preventing overselling and duplicate
 * orders.
 */
export const createOrder = functions.https.onCall(async (request) => {
  // ── Step 1: Authenticate ─────────────────────────────────────────────────
  const auth = request.auth;
  if (!auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'You must be signed in to place an order.'
    );
  }
  const uid = auth.uid;
  const requestId = `order_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`;
  logger.info('createOrder attempt', { requestId, uid });

  const data = request.data as CreateOrderRequest;

  // ── Step 2: Validate input shape ─────────────────────────────────────────
  if (
    !data.storeId ||
    typeof data.storeId !== 'string' ||
    !Array.isArray(data.items) ||
    data.items.length === 0 ||
    !data.paymentMethod ||
    typeof data.paymentMethod !== 'string'
  ) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'storeId (string), items (non-empty array), and paymentMethod (string) are required.'
    );
  }

  // ── P9: Payment method whitelist ─────────────────────────────────────────
  const paymentMethod = data.paymentMethod.toLowerCase();
  if (!ALLOWED_PAYMENT_METHODS.includes(paymentMethod)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Invalid payment method. Allowed: ${ALLOWED_PAYMENT_METHODS.join(', ')}.`
    );
  }

  // ── P5: Distinct product cap ─────────────────────────────────────────────
  if (data.items.length > MAX_DISTINCT_PRODUCTS) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Too many distinct products. Maximum is ${MAX_DISTINCT_PRODUCTS}.`
    );
  }

  let totalRequestedQuantity = 0;
  for (const item of data.items) {
    if (
      !item.productId ||
      typeof item.productId !== 'string' ||
      typeof item.quantity !== 'number' ||
      !Number.isInteger(item.quantity) ||
      item.quantity <= 0
    ) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Each item must have a productId (string) and quantity (positive integer).'
      );
    }
    // ── P5: Per-item quantity cap ──────────────────────────────────────────
    if (item.quantity > MAX_QUANTITY_PER_ITEM) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Maximum quantity per item is ${MAX_QUANTITY_PER_ITEM}.`
      );
    }
    totalRequestedQuantity += item.quantity;
  }

  // ── P5: Total items cap ──────────────────────────────────────────────────
  if (totalRequestedQuantity > MAX_TOTAL_ITEMS) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Total items in order cannot exceed ${MAX_TOTAL_ITEMS}.`
    );
  }

  const orderNote =
    data.orderNote && typeof data.orderNote === 'string'
      ? data.orderNote.substring(0, 500)
      : null;

  // Validate idempotency key format (if provided)
  const idempotencyKey =
    data.idempotencyKey && typeof data.idempotencyKey === 'string'
      ? data.idempotencyKey.substring(0, 128)
      : null;

  try {
    // ── P8: Idempotency pre-check (fast path outside transaction) ────────
    // A query outside the transaction provides a fast exit for obvious
    // duplicates. The authoritative check is inside the transaction below.
    if (idempotencyKey) {
      const existing = await db
        .collection('orderRequests')
        .where('idempotencyKey', '==', idempotencyKey)
        .where('userId', '==', uid)
        .limit(1)
        .get();

      if (!existing.empty) {
        const existingOrderId = existing.docs[0].data().orderId as string;
        logger.info('Duplicate order request detected (fast path)', { requestId, uid, idempotencyKey, existingOrderId });
        return { success: true, orderId: existingOrderId } as CreateOrderResponse;
      }
    }

    // ── Step 3: Fetch user profile (outside transaction — immutable) ─────
    const userSnap = await db.collection('users').doc(uid).get();
    if (!userSnap.exists) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'User profile not found.'
      );
    }

    const userData = userSnap.data()!;
    const firstName: string = userData.firstName ?? '';
    const lastName: string = userData.lastName ?? '';
    const phone: string = userData.phoneNumber ?? '';
    const addresses: any[] = userData.addresses ?? [];

    if (addresses.length === 0) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'No delivery address found on your profile.'
      );
    }

    const address = addresses[0];
    const name = `${firstName} ${lastName}`.trim();

    // ── Step 4–7: Transaction (store + products + stock + order write) ────
    const orderId = await db.runTransaction(async (tx) => {
      // ── 4a: Fetch store & validate ───────────────────────────────────────
      const storeRef = db.collection('stores').doc(data.storeId);
      const storeSnap = await tx.get(storeRef);
      if (!storeSnap.exists) {
        throw new functions.https.HttpsError('not-found', 'Store not found.');
      }
      const storeData = storeSnap.data()!;

      if (!storeData.isActive) {
        throw new functions.https.HttpsError('failed-precondition', 'This store is currently inactive.');
      }
      if (!storeData.isApproved) {
        throw new functions.https.HttpsError('failed-precondition', 'This store is not yet approved.');
      }
      if (!storeData.isOpen) {
        throw new functions.https.HttpsError('failed-precondition', 'This store is currently closed.');
      }

      // ── 4b: P7 — Batch-read all products in one round trip ───────────────
      const productRefs = data.items.map(
        (item) => db.collection('products').doc(item.productId)
      );
      const productSnaps = await tx.getAll(...productRefs);

      // ── 5: Validate products, compute totals, build order items ──────────
      const orderItems: any[] = [];
      let subtotal = 0;
      let totalWeight = 0;

      for (let i = 0; i < data.items.length; i++) {
        const reqItem = data.items[i];
        const productSnap = productSnaps[i];

        if (!productSnap.exists) {
          throw new functions.https.HttpsError(
            'not-found',
            `Product ${reqItem.productId} not found.`
          );
        }

        const product = productSnap.data()!;

        // ── P6: Verify product belongs to the requested store ──────────────
        if (product.storeId !== data.storeId) {
          throw new functions.https.HttpsError(
            'invalid-argument',
            `Product "${product.name ?? reqItem.productId}" does not belong to this store.`
          );
        }

        if (product.isAvailable === false) {
          throw new functions.https.HttpsError(
            'failed-precondition',
            `Product "${product.name ?? reqItem.productId}" is currently unavailable.`
          );
        }

        // ── P4: Stock validation ───────────────────────────────────────────
        const currentStock: number = product.quantity ?? 0;
        if (currentStock < reqItem.quantity) {
          throw new functions.https.HttpsError(
            'failed-precondition',
            `Insufficient stock for "${product.name ?? reqItem.productId}". Available: ${currentStock}, requested: ${reqItem.quantity}.`
          );
        }

        // Use discountPrice if available, otherwise regular price
        const unitPrice: number =
          product.discountPrice != null && product.discountPrice > 0
            ? product.discountPrice
            : product.price;

        const unitWeight: number = product.weight ?? 0;
        const quantity = reqItem.quantity;

        const lineTotal = unitPrice * quantity;
        const lineWeight = unitWeight * quantity;

        subtotal += lineTotal;
        totalWeight += lineWeight;

        orderItems.push({
          productId: reqItem.productId,
          storeId: data.storeId,
          name: product.name ?? '',
          imageUrl: (product.images && product.images.length > 0) ? product.images[0] : null,
          price: unitPrice,
          weight: unitWeight,
          quantity: quantity,
        });
      }

      // ── 6: Compute delivery fee (mirrors delivery_fee_helper.dart) ───────
      const freeDeliveryOver: number | null = storeData.freeDeliveryOver ?? null;
      const deliveryPricing: { maxWeight: number; fee: number }[] =
        storeData.deliveryPricing ?? [];

      let deliveryFee = 0;

      if (freeDeliveryOver != null && subtotal >= freeDeliveryOver) {
        deliveryFee = 0;
      } else {
        let matched = false;
        for (const rule of deliveryPricing) {
          if (totalWeight <= rule.maxWeight) {
            deliveryFee = rule.fee;
            matched = true;
            break;
          }
        }
        if (!matched && deliveryPricing.length > 0) {
          deliveryFee = deliveryPricing[deliveryPricing.length - 1].fee;
        }
      }

      const total = subtotal + deliveryFee;

      // ── 6b: Enforce minimum order amount ─────────────────────────────────
      const minimumOrderAmount: number = storeData.minimumOrderAmount ?? 0;
      if (subtotal < minimumOrderAmount) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          `Minimum order amount is ${minimumOrderAmount}. Your subtotal is ${subtotal.toFixed(2)}.`
        );
      }

      // ── 7a: P4 — Decrement stock atomically ─────────────────────────────
      for (let i = 0; i < data.items.length; i++) {
        tx.update(productRefs[i], {
          quantity: admin.firestore.FieldValue.increment(-data.items[i].quantity),
        });
      }

      // ── 7b: Write order document ─────────────────────────────────────────
      const orderRef = db.collection('orders').doc();
      tx.set(orderRef, {
        userId: uid,
        storeId: data.storeId,
        items: orderItems,
        subtotal: Math.round(subtotal * 100) / 100,
        deliveryFee: Math.round(deliveryFee * 100) / 100,
        total: Math.round(total * 100) / 100,
        totalWeight: Math.round(totalWeight * 1000) / 1000,
        status: 'pending',
        paymentStatus: 'unpaid',
        paymentMethod,
        name,
        phone,
        address,
        orderNote,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // ── 7c: P8 — Persist idempotency record inside transaction ───────────
      if (idempotencyKey) {
        const idempotencyRef = db.collection('orderRequests').doc();
        tx.set(idempotencyRef, {
          idempotencyKey,
          userId: uid,
          orderId: orderRef.id,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      return orderRef.id;
    }); // end transaction

    // ── P10: Server-side cart cleanup ───────────────────────────────────────
    // Best-effort — if this fails the order still succeeded.
    try {
      await db
        .collection('users')
        .doc(uid)
        .collection('carts')
        .doc(data.storeId)
        .delete();
    } catch (cartErr) {
      logger.warn('Failed to clean up cart after order', {
        requestId, uid, storeId: data.storeId,
        error: cartErr instanceof Error ? cartErr.message : 'Unknown',
      });
    }

    logger.info('Order created successfully', {
      requestId,
      uid,
      orderId,
      paymentMethod,
    });

    return { success: true, orderId } as CreateOrderResponse;
  } catch (error) {
    // Re-throw HttpsErrors as-is so the client gets the proper code
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    logger.error('createOrder failed', {
      requestId,
      uid,
      error: error instanceof Error ? error.message : 'Unknown error',
    });

    throw new functions.https.HttpsError(
      'internal',
      'Failed to place order. Please try again.'
    );
  }
});
