import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/checkout/services/checkout_service.dart';
import 'package:sudan_goods/checkout/services/payment_service.dart';
import 'package:sudan_goods/models/store/store_model.dart';
import 'package:sudan_goods/order/order_success_page.dart';

/// Controller responsible for validating checkout inputs,
/// creating orders, and handling checkout navigation UX.
class CheckoutController with ChangeNotifier {
  bool isLoading = false;
  final CheckoutService checkoutService;

  CheckoutController({required this.checkoutService});

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

  /// Pays via Stripe PaymentSheet and navigates to the success screen.
  ///
  /// Calls [PaymentService] which:
  ///   1. Creates a Stripe PaymentIntent server-side (no Firestore order yet).
  ///   2. Presents the Stripe PaymentSheet to the user.
  ///
  /// The Firestore order is created by the backend webhook after
  /// `payment_intent.succeeded` fires — guaranteeing no ghost orders.
  Future<void> payAndPlaceOrder(
    BuildContext context, {
    required Store store,
    required String note,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await PaymentService().pay(context, storeId: store.id, orderNote: note);

      // Payment confirmed by Stripe — clear cart client-side.
      // Server-side cleanup happens in the webhook.
      if (context.mounted) {
        context.read<CartController>().clearCart(store.id);
        showSuccessScreen(context);
      }
    } on CheckoutException catch (e) {
      if (e.message == 'Payment cancelled.') {
        // User dismissed the sheet — stay on checkout, no error toast
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
  void showSuccessScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OrderSuccessPage()),
      (route) => route.isFirst,
    );
  }
}
