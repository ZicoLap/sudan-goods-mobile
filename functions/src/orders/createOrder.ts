import * as functions from 'firebase-functions';
import * as logger from 'firebase-functions/logger';
import * as admin from 'firebase-admin';
import { CreateOrderRequest, CreateOrderResponse } from './types';

const db = admin.firestore();

/**
 * Cloud Callable Function: createOrder
 *
 * Receives minimal input from the client, fetches authoritative product/store
 * data from Firestore, computes totals server-side, and writes the order
 * document using Admin SDK (bypasses security rules).
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
    // ── Idempotency check ──────────────────────────────────────────────────
    if (idempotencyKey) {
      const existing = await db
        .collection('orderRequests')
        .where('idempotencyKey', '==', idempotencyKey)
        .where('userId', '==', uid)
        .limit(1)
        .get();

      if (!existing.empty) {
        const existingOrderId = existing.docs[0].data().orderId as string;
        logger.info('Duplicate order request detected', { requestId, uid, idempotencyKey, existingOrderId });
        return { success: true, orderId: existingOrderId } as CreateOrderResponse;
      }
    }
    // ── Step 3: Fetch user profile ───────────────────────────────────────────
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

    // ── Step 4: Fetch store & validate ────────────────────────────────────────
    const storeSnap = await db.collection('stores').doc(data.storeId).get();
    if (!storeSnap.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'Store not found.'
      );
    }
    const storeData = storeSnap.data()!;

    if (!storeData.isActive) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'This store is currently inactive.'
      );
    }
    if (!storeData.isApproved) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'This store is not yet approved.'
      );
    }
    if (!storeData.isOpen) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'This store is currently closed.'
      );
    }

    // ── Step 5: Fetch products & compute totals ──────────────────────────────
    const orderItems: any[] = [];
    let subtotal = 0;
    let totalWeight = 0;

    for (const reqItem of data.items) {
      const productSnap = await db.collection('products').doc(reqItem.productId).get();
      if (!productSnap.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          `Product ${reqItem.productId} not found.`
        );
      }

      const product = productSnap.data()!;

      if (product.isAvailable === false) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          `Product "${product.name ?? reqItem.productId}" is currently unavailable.`
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

    // ── Step 6: Compute delivery fee (mirrors delivery_fee_helper.dart) ──────
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

    // ── Step 6b: Enforce minimum order amount ────────────────────────────────
    const minimumOrderAmount: number = storeData.minimumOrderAmount ?? 0;
    if (subtotal < minimumOrderAmount) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        `Minimum order amount is ${minimumOrderAmount}. Your subtotal is ${subtotal.toFixed(2)}.`
      );
    }

    // ── Step 7: Write order document ─────────────────────────────────────────
    const orderDoc = {
      userId: uid,
      storeId: data.storeId,
      items: orderItems,
      subtotal: Math.round(subtotal * 100) / 100,
      deliveryFee: Math.round(deliveryFee * 100) / 100,
      total: Math.round(total * 100) / 100,
      totalWeight: Math.round(totalWeight * 1000) / 1000,
      status: 'pending',
      paymentStatus: 'unpaid',
      paymentMethod: data.paymentMethod.toLowerCase(),
      name,
      phone,
      address,
      orderNote,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const docRef = await db.collection('orders').add(orderDoc);

    // ── Persist idempotency record ───────────────────────────────────────────
    if (idempotencyKey) {
      await db.collection('orderRequests').add({
        idempotencyKey,
        userId: uid,
        orderId: docRef.id,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    logger.info('Order created successfully', {
      requestId,
      uid,
      orderId: docRef.id,
      total: orderDoc.total,
    });

    const response: CreateOrderResponse = {
      success: true,
      orderId: docRef.id,
    };

    return response;
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
