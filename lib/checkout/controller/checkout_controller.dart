import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudan_goods/models/shared_models/address.dart';
import 'package:sudan_goods/models/store/cart_item_model.dart';
import 'package:sudan_goods/models/store/order_model.dart' as order_model;
import 'package:sudan_goods/order/order_service.dart';
import 'package:sudan_goods/order/order_success_page.dart';

/// Controller responsible for validating checkout inputs,
/// creating orders, and handling checkout navigation UX.
class CheckoutController with ChangeNotifier {
  bool isLoading = false;

  /// Validates input, creates an order, clears the cart and navigates
  /// to success screen. Shows a snackbar on failure.
  ///
  /// Parameters:
  /// - [context]: Build context used for snackbar and navigation.
  /// - [userId]: ID of the customer placing the order.
  /// - [storeId]: ID of the store for which the order is placed.
  /// - [cartItems]: Line items to be included in the order.
  /// - [subtotal]: Items subtotal before delivery fee.
  /// - [deliveryFee]: Delivery cost calculated for this order.
  /// - [total]: Final order total (subtotal + deliveryFee).
  /// - [totalWeight]: Total weight used for delivery pricing.
  /// - [name], [phone], [address]: Customer contact and delivery info.
  /// - [orderNote]: Optional note provided by the customer.
  /// - [paymentStatus], [paymentMethod]: Payment info used for validation.
  Future<void> placeOrder({
    required BuildContext context,
    required String userId,
    required String storeId,
    required List<CartItem> cartItems,
    required double subtotal,
    required double deliveryFee,
    required double total,
    required double totalWeight,
    required String name,
    required String phone,
    required Address address,
    String? orderNote,
    required String paymentStatus,
    required String paymentMethod,
  }) async {
    if (!validateCheckoutInputs(
      context: context,
      cartItems: cartItems,
      name: name,
      phone: phone,
      address: address,
      subtotal: subtotal,
      total: total,
      paymentStatus: paymentStatus,
    )) {
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      final newOrder = order_model.Order(
        userId: userId,
        storeId: storeId,
        items: cartItems,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: total,
        totalWeight: totalWeight,
        status: 'pending',
        paymentStatus: paymentStatus,
        paymentMethod: paymentMethod,
        name: name,
        phone: phone,
        address: address,
        orderNote: orderNote,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await OrderServices.createOrder(newOrder);

      clearCart(); // Call your cart clear logic
      showSuccessScreen(context);
    } catch (e) {
      showError(context, 'Failed to place order. Please try again.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Validates the checkout form and order data before placing an order.
  /// Returns `true` if all checks pass; otherwise shows a snackbar and
  /// returns `false`.
  bool validateCheckoutInputs({
    required BuildContext context,
    required List<CartItem> cartItems,
    required String name,
    required String phone,
    required Address address,
    required double subtotal,
    required double total,
    required String paymentStatus,
  }) {
    if (cartItems.isEmpty) {
      showError(context, 'Your cart is empty.');
      return false;
    }

    if (cartItems.any((item) => item.quantity <= 0)) {
      showError(context, 'One or more items have invalid quantity.');
      return false;
    }

    if (subtotal <= 0 || total <= 0) {
      showError(context, 'Order total is invalid.');
      return false;
    }

    if (name.trim().isEmpty) {
      showError(context, 'Please enter your name.');
      return false;
    }

    if (phone.trim().isEmpty) {
      showError(context, 'Please enter your phone number.');
      return false;
    }

    /*    if (address.trim().isEmpty) {
      showError(context, 'Please enter your delivery address.');
      return false;
    } */

    if (paymentStatus != 'paid') {
      showError(context, 'Payment not confirmed. Please try again.');
      return false;
    }

    return true;
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
      (route) => false,
    );
  }

  /// Placeholder for clearing cart logic (integrate with [CartController]).
  void clearCart() {
    // Clear your cart logic here (e.g., call CartController)
    print('🛒 Cart cleared');
  }
}
