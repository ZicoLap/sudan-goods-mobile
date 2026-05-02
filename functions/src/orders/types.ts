/**
 * Request shape expected from the client.
 */
export interface CreateOrderRequest {
  storeId: string;
  items: { productId: string; quantity: number }[];
  paymentMethod: string;
  orderNote?: string;
  idempotencyKey?: string;
  /** Fix #9: 0-based index into the user's saved addresses array. Defaults to 0. */
  addressIndex?: number;
}

/**
 * Successful response returned to the client.
 */
export interface CreateOrderResponse {
  success: true;
  orderId: string;
}

/**
 * Sanitised and validated request — produced by validateOrderInput().
 * All fields are guaranteed to be present and within allowed bounds.
 */
export interface ValidatedOrderInput {
  storeId: string;
  items: { productId: string; quantity: number }[];
  paymentMethod: string;
  orderNote: string | null;
  idempotencyKey: string | null;
  /** Fix #9: Validated 0-based address index. Always a non-negative integer. */
  addressIndex: number;
}

/**
 * A single line item in a placed order.
 * Stored inside the order document in Firestore.
 */
export interface OrderItem {
  productId: string;
  storeId: string;
  name: string;
  imageUrl: string | null;
  price: number;
  weight: number;
  quantity: number;
}

/**
 * Computed order totals — produced by buildOrderTotals().
 * All monetary values are rounded to 2 decimal places.
 */
export interface OrderTotals {
  subtotal: number;
  deliveryFee: number;
  total: number;
  totalWeight: number;
}

/**
 * User profile fields required for order creation.
 * Produced by fetchOrderUserProfile().
 */
export interface OrderUserProfile {
  name: string;
  phone: string;
  address: Record<string, unknown>;
}
