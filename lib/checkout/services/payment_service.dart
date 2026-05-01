import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'checkout_service.dart';

/// MINIMAL: Calls createPaymentIntent (fixed €5) and presents PaymentSheet.
/// No cart, no storeId, no order logic — baseline test only.
class PaymentService {
  Future<void> pay(BuildContext context) async {
    // ── 1: Get clientSecret from Cloud Function ───────────────────────────
    final String clientSecret;
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'createPaymentIntent',
      );
      final result = await callable.call({});
      clientSecret = result.data['clientSecret'] as String;
    } on FirebaseFunctionsException catch (e) {
      throw CheckoutException(e.message ?? 'Failed to create payment.');
    }

    // ── 2: Init PaymentSheet ──────────────────────────────────────────────
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Sudan Goods',
        style: ThemeMode.system,
      ),
    );

    // ── 3: Present PaymentSheet ───────────────────────────────────────────
    try {
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        throw CheckoutException('Payment cancelled.');
      }
      throw CheckoutException(
        e.error.localizedMessage ?? 'Payment failed. Please try again. ${e.error.code}',
      );
    }
  }
}
