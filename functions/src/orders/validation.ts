import * as functions from 'firebase-functions';
import { CreateOrderRequest, ValidatedOrderInput } from './types';

// ── Order limits ───────────────────────────────────────────────────────────────
export const MAX_QUANTITY_PER_ITEM = 50;
export const MAX_TOTAL_ITEMS = 200;
export const MAX_DISTINCT_PRODUCTS = 20;
export const ALLOWED_PAYMENT_METHODS = ['card', 'cash_on_delivery'];

/**
 * Validates the raw createOrder request payload.
 *
 * Pure function — no Firebase imports, fully unit-testable.
 * Throws HttpsError('invalid-argument') on any violation.
 * Returns a sanitised {@link ValidatedOrderInput} on success.
 */
export function validateOrderInput(data: unknown): ValidatedOrderInput {
  if (!data || typeof data !== 'object') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Request body must be an object.'
    );
  }

  const raw = data as Partial<CreateOrderRequest>;

  // ── Required string fields ─────────────────────────────────────────────────
  if (!raw.storeId || typeof raw.storeId !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'storeId (string) is required.'
    );
  }
  // Fix #14: Trim and clamp to prevent oversized inputs from reaching Firestore.
  const storeId = raw.storeId.trim().substring(0, 128);
  if (!storeId) {
    throw new functions.https.HttpsError('invalid-argument', 'storeId must not be blank.');
  }

  if (!raw.paymentMethod || typeof raw.paymentMethod !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'paymentMethod (string) is required.'
    );
  }

  // ── Payment method whitelist ───────────────────────────────────────────────
  const paymentMethod = raw.paymentMethod.toLowerCase();
  if (!ALLOWED_PAYMENT_METHODS.includes(paymentMethod)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Invalid payment method. Allowed: ${ALLOWED_PAYMENT_METHODS.join(', ')}.`
    );
  }

  // ── Items array ────────────────────────────────────────────────────────────
  if (!Array.isArray(raw.items) || raw.items.length === 0) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'items must be a non-empty array.'
    );
  }

  if (raw.items.length > MAX_DISTINCT_PRODUCTS) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Too many distinct products. Maximum is ${MAX_DISTINCT_PRODUCTS}.`
    );
  }

  let totalRequestedQuantity = 0;
  for (const item of raw.items) {
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

    if (item.quantity > MAX_QUANTITY_PER_ITEM) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Maximum quantity per item is ${MAX_QUANTITY_PER_ITEM}.`
      );
    }

    totalRequestedQuantity += item.quantity;
  }

  if (totalRequestedQuantity > MAX_TOTAL_ITEMS) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Total items in order cannot exceed ${MAX_TOTAL_ITEMS}.`
    );
  }

  // Fix #6: Reject duplicate productIds — they cause double stock decrements
  // and inflated subtotals in the Firestore transaction.
  const seenProductIds = new Set<string>();
  for (const item of raw.items) {
    if (seenProductIds.has(item.productId)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Duplicate productId "${item.productId}" in items. Each product must appear only once.`
      );
    }
    seenProductIds.add(item.productId);
  }

  // ── Optional fields — sanitise ─────────────────────────────────────────────
  const orderNote =
    raw.orderNote && typeof raw.orderNote === 'string'
      ? raw.orderNote.substring(0, 500)
      : null;

  const idempotencyKey =
    raw.idempotencyKey && typeof raw.idempotencyKey === 'string'
      ? raw.idempotencyKey.substring(0, 128)
      : null;

  // Fix #9: Validate addressIndex — must be a non-negative integer if provided.
  let addressIndex = 0;
  if (raw.addressIndex !== undefined && raw.addressIndex !== null) {
    if (
      typeof raw.addressIndex !== 'number' ||
      !Number.isInteger(raw.addressIndex) ||
      raw.addressIndex < 0
    ) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'addressIndex must be a non-negative integer.'
      );
    }
    addressIndex = raw.addressIndex;
  }

  return {
    storeId,
    items: raw.items as { productId: string; quantity: number }[],
    paymentMethod,
    orderNote,
    idempotencyKey,
    addressIndex,
  };
}
