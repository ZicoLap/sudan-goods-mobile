import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:uuid/uuid.dart';

import 'checkout_service.dart';

/// Orchestrates the Stripe PaymentSheet flow.
///
/// 1. Reads cart from [CartController] and generates an idempotency key.
/// 2. Calls [createPaymentIntent] Cloud Function — server validates cart,
///    computes authoritative total, returns clientSecret.
/// 3. Initialises and presents the Stripe PaymentSheet.
///
/// The Firestore order is created by [stripeWebhook] after
/// payment_intent.succeeded — guaranteeing no ghost orders.
class PaymentService {
  Future<void> pay(
    BuildContext context, {
    required String storeId,
    required String? orderNote,
  }) async {
    final cart = Provider.of<CartController>(context, listen: false);
    final cartItems = cart.getItemsByStore(storeId);
    if (cartItems.isEmpty) throw CheckoutException('Your cart is empty.');

    final items =
        cartItems
            .map((e) => {'productId': e.productId, 'quantity': e.quantity})
            .toList();

    final idempotencyKey = const Uuid().v4();

    // ── 1: Create PaymentIntent on the server ─────────────────────────────
    final String clientSecret;
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'createPaymentIntent',
      );
      final result = await callable.call({
        'storeId': storeId,
        'items': items,
        if (orderNote != null && orderNote.isNotEmpty) 'orderNote': orderNote,
        'idempotencyKey': idempotencyKey,
      });
      clientSecret = result.data['clientSecret'] as String;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'already-exists') return; // already paid — treat as success
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
        e.error.localizedMessage ?? 'Payment failed. Please try again.',
      );
    }
  }
}
