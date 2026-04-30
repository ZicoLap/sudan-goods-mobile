/**
 * Request shape expected from the client.
 */
export interface CreateOrderRequest {
  storeId: string;
  items: { productId: string; quantity: number }[];
  paymentMethod: string;
  orderNote?: string;
  idempotencyKey?: string;
}

/**
 * Successful response returned to the client.
 */
export interface CreateOrderResponse {
  success: true;
  orderId: string;
}
