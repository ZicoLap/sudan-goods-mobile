import { OrderItem, OrderTotals } from './types';

/**
 * Delivery pricing tier as stored in the store document.
 */
export interface DeliveryRule {
  maxWeight: number;
  fee: number;
}

/**
 * The store fields required to compute a delivery fee.
 */
export interface StoreDeliveryConfig {
  freeDeliveryOver?: number | null;
  deliveryPricing?: DeliveryRule[];
  minimumOrderAmount?: number;
}

/**
 * Resolves the effective unit price for a product.
 *
 * Uses discountPrice when it is set and greater than zero,
 * otherwise falls back to the regular price.
 *
 * Pure function — no Firebase imports.
 */
export function resolveUnitPrice(product: {
  price: number;
  discountPrice?: number | null;
}): number {
  return product.discountPrice != null && product.discountPrice > 0
    ? product.discountPrice
    : product.price;
}

/**
 * Computes the delivery fee for an order.
 *
 * Mirrors the logic in `delivery_fee_helper.dart` on the client.
 * Pure function — no Firebase imports, fully unit-testable.
 *
 * @param config  - Store-level delivery settings.
 * @param subtotal    - Order subtotal (sum of line totals).
 * @param totalWeight - Total weight of all items in the order (kg).
 */
export function calculateDeliveryFee(
  config: StoreDeliveryConfig,
  subtotal: number,
  totalWeight: number
): number {
  const freeDeliveryOver = config.freeDeliveryOver ?? null;
  const rules: DeliveryRule[] = config.deliveryPricing ?? [];

  if (freeDeliveryOver != null && subtotal >= freeDeliveryOver) {
    return 0;
  }

  for (const rule of rules) {
    if (totalWeight <= rule.maxWeight) {
      return rule.fee;
    }
  }

  // Fallback: use the highest tier fee when no rule matches
  return rules.length > 0 ? rules[rules.length - 1].fee : 0;
}

/**
 * Builds the complete set of order totals from a list of resolved order items
 * and the store's delivery configuration.
 *
 * Pure function — no Firebase imports, fully unit-testable.
 * All monetary values are rounded to 2 decimal places.
 * Weight is rounded to 3 decimal places.
 */
export function buildOrderTotals(
  items: OrderItem[],
  config: StoreDeliveryConfig
): OrderTotals {
  let rawSubtotal = 0;
  let rawTotalWeight = 0;

  for (const item of items) {
    rawSubtotal += item.price * item.quantity;
    rawTotalWeight += item.weight * item.quantity;
  }

  const subtotal = Math.round(rawSubtotal * 100) / 100;
  const totalWeight = Math.round(rawTotalWeight * 1000) / 1000;
  const deliveryFee = Math.round(calculateDeliveryFee(config, subtotal, totalWeight) * 100) / 100;
  const total = Math.round((subtotal + deliveryFee) * 100) / 100;

  return { subtotal, deliveryFee, total, totalWeight };
}
