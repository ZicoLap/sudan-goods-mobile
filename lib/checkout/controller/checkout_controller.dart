import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/checkout/services/checkout_service.dart';
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
