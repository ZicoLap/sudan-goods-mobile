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

  /// Places an order using [CheckoutService].
  ///
  /// This method delegates building totals, fetching user/address, and order
  /// persistence to the service. On success it clears the cart for the store
  /// and navigates to the success screen while preserving the tab root.
  Future<void> placeOrderViaService(
    BuildContext context, {
    required Store store,
    required String note,
    required String paymentMethod,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final order = await checkoutService.buildOrder(
        context,
        store: store,
        note: note,
        selectedPaymentMethod: paymentMethod,
      );

      await checkoutService.createOrder(order);

      // Clear cart for this store
      context.read<CartController>().clearCart(order.storeId);

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

  // All validation and totals computation is performed in CheckoutService.

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
