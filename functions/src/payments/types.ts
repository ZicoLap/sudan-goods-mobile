/**
 * Request shape for the createPaymentIntent callable function.
 */
export interface CreatePaymentIntentRequest {
  storeId: string;
  items: { productId: string; quantity: number }[];
  orderNote?: string;
  idempotencyKey?: string;
}

/**
 * Response returned to the Flutter client.
 * clientSecret is passed directly to Stripe PaymentSheet.
 */
export interface CreatePaymentIntentResponse {
  clientSecret: string;
}
