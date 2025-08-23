/// Payment Gateway abstraction to enable pluggable payment providers.
///
/// This is intentionally minimal for now. In the Stripe phase, implement
/// [StripePaymentGateway] that conforms to this interface and wire it into
/// CheckoutService before creating the order.
abstract class PaymentGateway {
  /// Initiates and confirms a payment for the current checkout context.
  /// Returns a [PaymentResult] describing success/failure.
  Future<PaymentResult> confirmPayment({
    required int amountInMinorUnits, // e.g., cents
    required String currency, // e.g., 'USD'
    required String description,
    Map<String, Object?> metadata,
  });
}

/// Normalized payment result for the app. Do not expose provider-specific
/// types outside of the payment layer.
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? errorMessage;

  const PaymentResult.success(this.transactionId)
      : success = true,
        errorMessage = null;

  const PaymentResult.failure(this.errorMessage)
      : success = false,
        transactionId = null;
}
