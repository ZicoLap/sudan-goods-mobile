import * as functions from 'firebase-functions';
import * as logger from 'firebase-functions/logger';
import { randomUUID } from 'crypto';
import { CreateOrderResponse } from './types';
import { validateOrderInput } from './validation';
import { checkIdempotency, runOrderTransaction, cleanupCart } from './orderRepository';
import { fetchOrderUserProfile } from '../services/userService';

/**
 * Cloud Callable Function: createOrder
 *
 * Thin orchestrator — delegates all business logic to focused modules:
 *   - validation.ts     → input validation
 *   - services/userService.ts → user profile fetch
 *   - orderRepository.ts → Firestore transaction (store, products, stock, order write)
 *   - pricing.ts         → price / delivery fee calculation (used inside repository)
 *
 * All reads, stock decrements, and writes happen inside a single Firestore
 * transaction inside runOrderTransaction() to guarantee atomicity.
 */
export const createOrder = functions.https.onCall(async (request) => {
  // ── 1: Authenticate ───────────────────────────────────────────────────────
  const auth = request.auth;
  if (!auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'You must be signed in to place an order.'
    );
  }
  const uid = auth.uid;
  // Fix #8: Use crypto.randomUUID() to avoid log-ID collisions under concurrency.
  const requestId = `order_${randomUUID()}`;
  logger.info('createOrder attempt', { requestId, uid });

  try {
    // ── 2: Validate & sanitise input ─────────────────────────────────────────
    const input = validateOrderInput(request.data);

    // ── 3: Fast-path idempotency check ───────────────────────────────────────
    if (input.idempotencyKey) {
      const existingOrderId = await checkIdempotency(input.idempotencyKey, uid);
      if (existingOrderId) {
        logger.info('Duplicate order request (fast path)', { requestId, uid, existingOrderId });
        return { success: true, orderId: existingOrderId } as CreateOrderResponse;
      }
    }

    // ── 4: Fetch user profile ────────────────────────────────────────────────
    // Fix #9: Pass the client-selected address index.
    const userProfile = await fetchOrderUserProfile(uid, input.addressIndex);

    // ── 5: Run atomic transaction (store + products + stock + order write) ───
    const orderId = await runOrderTransaction({ uid, input, userProfile });

    // ── 6: Best-effort cart cleanup ──────────────────────────────────────────
    await cleanupCart(uid, input.storeId, requestId);

    logger.info('Order created successfully', {
      requestId, uid, orderId, paymentMethod: input.paymentMethod,
    });

    return { success: true, orderId } as CreateOrderResponse;
  } catch (error) {
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
