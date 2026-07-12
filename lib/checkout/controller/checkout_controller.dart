import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/checkout/services/checkout_service.dart';
import 'package:sudan_goods/checkout/services/payment_service.dart';
import 'package:sudan_goods/models/store/store_model.dart';
import 'package:sudan_goods/order/order_success_page.dart';
import 'package:uuid/uuid.dart';

/// Controller responsible for validating checkout inputs,
/// creating orders, and handling checkout navigation UX.
class CheckoutController with ChangeNotifier {
  bool isLoading = false;
  final CheckoutService checkoutService;

  /// I2: Generated once per checkout session. Stable across retries so the
  /// same PaymentIntent is reused if the user taps Pay more than once.
  /// Reset to a new value after a successful payment.
  String _idempotencyKey = const Uuid().v4();

  CheckoutController({required this.checkoutService});

  /// Resets the idempotency key — call after a successful order so the next
  /// checkout attempt gets a fresh key.
  void _resetIdempotencyKey() {
    _idempotencyKey = const Uuid().v4();
  }

  /// Places an order via the Cloud Function through [CheckoutService].
  ///
  /// Sends only minimal data (storeId, item IDs + quantities, payment method,
  /// note). All totals, user info, and product prices are resolved server-side.
  /// On success it clears the cart for the store and navigates to the success
  /// screen while preserving the tab root.
  Future<void> placeOrderViaService(
    BuildContext context, {
    required Store store,
    required String note,
    required String paymentMethod,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await checkoutService.placeOrder(
        context,
        storeId: store.id,
        note: note,
        paymentMethod: paymentMethod,
      );

      // Clear cart for this store
      context.read<CartController>().clearCart(store.id);

      showSuccessScreen(context);
    } on CheckoutException catch (e) {
      showError(context, e.message);
    } catch (_) {
      showError(context, 'Failed to place order. Please try again.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// C1: Computes the same deterministic document ID used by the backend
  /// (`sha256(uid::idempotencyKey)`) so we can poll `orderRequests/{docId}`.
  String _idempotencyDocId(String uid, String key) {
    final bytes = utf8.encode('$uid::$key');
    return sha256.convert(bytes).toString();
  }

  /// C1: Polls `orderRequests/{docId}` until the document appears or
  /// [timeout] elapses. Returns true if confirmed, false on timeout.
  Future<bool> _waitForOrder({
    required String uid,
    required String key,
    Duration timeout = const Duration(seconds: 15),
    Duration interval = const Duration(seconds: 2),
  }) async {
    final docId = _idempotencyDocId(uid, key);
    final ref = FirebaseFirestore.instance
        .collection('orderRequests')
        .doc(docId);
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      try {
        final snap = await ref.get();
        if (snap.exists) return true;
      } catch (_) {
        // Transient read error — keep polling.
      }
      await Future.delayed(interval);
    }
    return false;
  }

  /// Pays via Stripe PaymentSheet and navigates to the success screen.
  ///
  /// Calls [PaymentService] which:
  ///   1. Creates a Stripe PaymentIntent server-side (no Firestore order yet).
  ///   2. Presents the Stripe PaymentSheet to the user.
  ///
  /// C1: After PaymentSheet closes, polls `orderRequests` until the webhook
  /// creates the Firestore order, then navigates to the success screen.
  Future<void> payAndPlaceOrder(
    BuildContext context, {
    required Store store,
    required String note,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final keyUsed = _idempotencyKey;

      await PaymentService().pay(
        context,
        storeId: store.id,
        orderNote: note,
        idempotencyKey: keyUsed,
      );

      // PaymentSheet completed — clear cart immediately for snappy UX.
      if (context.mounted) {
        context.read<CartController>().clearCart(store.id);
      }

      // C1: Poll until the webhook has written the order to Firestore.
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final confirmed = await _waitForOrder(uid: uid, key: keyUsed);

      _resetIdempotencyKey();

      if (context.mounted) {
        showSuccessScreen(context, confirmed: confirmed);
      }
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'already-exists') {
        // I5: A confirmed order already exists for this key.
        // Clear the cart and navigate to success — the order went through.
        if (context.mounted) {
          context.read<CartController>().clearCart(store.id);
          _resetIdempotencyKey();
          showSuccessScreen(context, confirmed: true);
        }
        return;
      }
      if (context.mounted) {
        showError(context, e.message ?? 'Payment failed. Please try again.');
      }
    } on CheckoutException catch (e) {
      if (e.message == 'Payment cancelled.') {
        // User dismissed the sheet — stay on checkout, no error toast.
        return;
      }
      if (context.mounted) showError(context, e.message);
    } on StripeException catch (e) {
      if (context.mounted) {
        showError(
          context,
          e.error.localizedMessage ?? 'Payment failed. Please try again.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        showError(context, 'Payment failed. Please try again.');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Shows a red snackbar with the provided [message].
  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  /// Navigates to the success screen and clears the navigation stack.
  /// [confirmed] is true when the Firestore order was confirmed via polling.
  void showSuccessScreen(BuildContext context, {bool confirmed = true}) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => OrderSuccessPage(confirmed: confirmed)),
      (route) => route.isFirst,
    );
  }
}
