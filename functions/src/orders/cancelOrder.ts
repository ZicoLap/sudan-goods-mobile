import * as functions from 'firebase-functions';
import * as logger from 'firebase-functions/logger';
import * as admin from 'firebase-admin';
import { OrderItem } from './types';

const db = admin.firestore();

/**
 * Callable Function: cancelOrder
 *
 * Cancels a pending order owned by the authenticated user.
 *
 * Steps (all atomic inside a Firestore transaction):
 *   1. Verify the order exists and belongs to the caller.
 *   2. Verify the order status is 'pending' (only pending orders may be cancelled).
 *   3. Restore stock for every item (increment product.quantity).
 *   4. Transition order status to 'cancelled'.
 *
 * Throws HttpsError on any violation so the client receives a clear message.
 */
export const cancelOrder = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'You must be signed in to cancel an order.'
    );
  }

  const uid = request.auth.uid;
  const orderId = request.data?.orderId;

  if (!orderId || typeof orderId !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'orderId (string) is required.'
    );
  }

  logger.info('cancelOrder attempt', { uid, orderId });

  try {
    await db.runTransaction(async (tx) => {
      const orderRef = db.collection('orders').doc(orderId);
      const orderSnap = await tx.get(orderRef);

      if (!orderSnap.exists) {
        throw new functions.https.HttpsError('not-found', 'Order not found.');
      }

      const order = orderSnap.data()!;

      if (order.userId !== uid) {
        throw new functions.https.HttpsError(
          'permission-denied',
          'You do not have permission to cancel this order.'
        );
      }

      if (order.status !== 'pending') {
        throw new functions.https.HttpsError(
          'failed-precondition',
          `This order cannot be cancelled (status: ${order.status}).`
        );
      }

      const items: OrderItem[] = order.items ?? [];

      for (const item of items) {
        const productRef = db.collection('products').doc(item.productId);
        tx.update(productRef, {
          quantity: admin.firestore.FieldValue.increment(item.quantity),
        });
      }

      tx.update(orderRef, {
        status: 'cancelled',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    logger.info('Order cancelled successfully', { uid, orderId });
    return { success: true };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    logger.error('cancelOrder failed', {
      uid,
      orderId,
      error: error instanceof Error ? error.message : 'Unknown error',
    });
    throw new functions.https.HttpsError(
      'internal',
      'Failed to cancel order. Please try again.'
    );
  }
});
