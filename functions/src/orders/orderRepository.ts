import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as logger from 'firebase-functions/logger';
import { createHash } from 'crypto';
import { ValidatedOrderInput, OrderItem, OrderTotals, OrderUserProfile } from './types';
import { resolveUnitPrice, buildOrderTotals, StoreDeliveryConfig } from './pricing';

/**
 * Fix #2: Deterministic document ID for idempotency records.
 *
 * Using a fixed doc ID (instead of auto-ID) allows tx.get() inside a
 * Firestore transaction, making the idempotency check truly atomic.
 * The key is hashed to stay within Firestore's 1500-byte doc ID limit.
 */
export function idempotencyDocId(uid: string, key: string): string {
  return createHash('sha256').update(`${uid}::${key}`).digest('hex');
}

const db = admin.firestore();

/**
 * Parameters passed into {@link runOrderTransaction}.
 */
export interface RunOrderTransactionParams {
  uid: string;
  input: ValidatedOrderInput;
  userProfile: OrderUserProfile;
}

/**
 * Fast-path idempotency check (outside transaction).
 *
 * Fix #2: Uses deterministic doc ID so the same key can also be read
 * atomically inside a Firestore transaction (see runOrderTransaction).
 *
 * Returns the existing orderId if a matching record is found,
 * or null if this is a new request.
 */
export async function checkIdempotency(
  idempotencyKey: string,
  uid: string
): Promise<string | null> {
  const docId = idempotencyDocId(uid, idempotencyKey);
  const snap = await db.collection('orderRequests').doc(docId).get();
  if (snap.exists) {
    return snap.data()!.orderId as string;
  }
  return null;
}

/**
 * Runs the full order creation inside a single Firestore transaction.
 *
 * Responsibilities (all atomic):
 * 1. Fetch & validate store (active, approved, open, minimum order).
 * 2. Batch-fetch all products (P7).
 * 3. Validate each product: existence, availability, store ownership (P6), stock (P4).
 * 4. Resolve prices and build order items.
 * 5. Compute totals via buildOrderTotals (pricing.ts).
 * 6. Decrement stock for each product (P4).
 * 7. Write the order document.
 * 8. Write the idempotency record (P8).
 *
 * Returns the new order document ID.
 */
export async function runOrderTransaction(
  params: RunOrderTransactionParams
): Promise<string> {
  const { uid, input, userProfile } = params;

  return db.runTransaction(async (tx) => {
    // ── 0: Authoritative in-transaction idempotency guard (Fix #2) ─────────
    // Reads the deterministic doc by ID — safe inside a transaction.
    // If it already exists, a concurrent request already committed an order.
    if (input.idempotencyKey) {
      const idempDocId = idempotencyDocId(uid, input.idempotencyKey);
      const idempSnap = await tx.get(db.collection('orderRequests').doc(idempDocId));
      if (idempSnap.exists) {
        const existingOrderId = idempSnap.data()!.orderId as string;
        throw new functions.https.HttpsError(
          'already-exists',
          `Order already placed (orderId: ${existingOrderId}).`
        );
      }
    }

    // ── 1: Fetch store & validate ──────────────────────────────────────────
    const storeRef = db.collection('stores').doc(input.storeId);
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

    // ── 2: Batch-read all products in one round trip (P7) ─────────────────
    const productRefs = input.items.map(
      (item) => db.collection('products').doc(item.productId)
    );
    const productSnaps = await tx.getAll(...productRefs);

    // ── 3 & 4: Validate products, resolve prices, build order items ────────
    const orderItems: OrderItem[] = [];

    for (let i = 0; i < input.items.length; i++) {
      const reqItem = input.items[i];
      const productSnap = productSnaps[i];

      if (!productSnap.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          `Product ${reqItem.productId} not found.`
        );
      }

      const product = productSnap.data()!;

      // P6: Product must belong to the requested store
      if (product.storeId !== input.storeId) {
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

      // P4: Stock check
      const currentStock: number = product.quantity ?? 0;
      if (currentStock < reqItem.quantity) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          `Insufficient stock for "${product.name ?? reqItem.productId}". ` +
          `Available: ${currentStock}, requested: ${reqItem.quantity}.`
        );
      }

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

    // ── 5: Compute totals ──────────────────────────────────────────────────
    const storeConfig: StoreDeliveryConfig = {
      freeDeliveryOver: storeData.freeDeliveryOver ?? null,
      deliveryPricing: storeData.deliveryPricing ?? [],
      minimumOrderAmount: storeData.minimumOrderAmount ?? 0,
    };

    const totals: OrderTotals = buildOrderTotals(orderItems, storeConfig);

    // Enforce minimum order amount
    const minimumOrderAmount = storeConfig.minimumOrderAmount ?? 0;
    if (totals.subtotal < minimumOrderAmount) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        `Minimum order amount is ${minimumOrderAmount}. Your subtotal is ${totals.subtotal.toFixed(2)}.`
      );
    }

    // ── 6: Decrement stock atomically (P4) ─────────────────────────────────
    for (let i = 0; i < input.items.length; i++) {
      tx.update(productRefs[i], {
        quantity: admin.firestore.FieldValue.increment(-input.items[i].quantity),
      });
    }

    // ── 7: Write order document ────────────────────────────────────────────
    const orderRef = db.collection('orders').doc();
    tx.set(orderRef, {
      userId: uid,
      storeId: input.storeId,
      items: orderItems,
      subtotal: totals.subtotal,
      deliveryFee: totals.deliveryFee,
      total: totals.total,
      totalWeight: totals.totalWeight,
      status: 'pending',
      paymentStatus: 'unpaid',
      paymentMethod: input.paymentMethod,
      name: userProfile.name,
      phone: userProfile.phone,
      address: userProfile.address,
      orderNote: input.orderNote,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // ── 8: Persist idempotency record inside transaction (Fix #2 P8) ───────
    // Uses the same deterministic doc ID checked in step 0.
    if (input.idempotencyKey) {
      const idempDocId = idempotencyDocId(uid, input.idempotencyKey);
      tx.set(db.collection('orderRequests').doc(idempDocId), {
        idempotencyKey: input.idempotencyKey,
        userId: uid,
        orderId: orderRef.id,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    return orderRef.id;
  });
}

/**
 * Deletes the user's cart for a given store after a successful order.
 *
 * Best-effort — errors are logged but do not fail the order.
 */
export async function cleanupCart(
  uid: string,
  storeId: string,
  requestId: string
): Promise<void> {
  try {
    await db
      .collection('users')
      .doc(uid)
      .collection('carts')
      .doc(storeId)
      .delete();
  } catch (err) {
    logger.warn('Failed to clean up cart after order', {
      requestId,
      uid,
      storeId,
      error: err instanceof Error ? err.message : 'Unknown',
    });
  }
}
