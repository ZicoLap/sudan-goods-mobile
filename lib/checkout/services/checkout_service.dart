import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/order/services/order_service.dart';
import 'package:uuid/uuid.dart';

/// Lightweight domain error for checkout failures.
class CheckoutException implements Exception {
  final String message;
  CheckoutException(this.message);
  @override
  String toString() => 'CheckoutException: $message';
}

/// Service that orchestrates checkout operations.
///
/// All pricing, validation, and order persistence now happen server-side
/// via the `createOrder` Cloud Function. This service is responsible only
/// for gathering minimal client input and calling the function.
class CheckoutService {
  final FirebaseAuth _auth;

  CheckoutService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Places an order via the Cloud Function.
  ///
  /// Reads only the cart item IDs + quantities from local state and sends
  /// them to the backend along with [storeId], [paymentMethod], and [note].
  /// All totals, user info, and product prices are resolved server-side.
  ///
  /// Returns the server-generated order ID on success.
  /// Throws [CheckoutException] with a user-friendly message on failure.
  Future<String> placeOrder(
    BuildContext context, {
    required String storeId,
    required String note,
    required String paymentMethod,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw CheckoutException('User not authenticated.');
    }

    final cart = Provider.of<CartController>(context, listen: false);
    final cartItems = cart.getItemsByStore(storeId);
    if (cartItems.isEmpty) {
      throw CheckoutException('Your cart is empty.');
    }

    // Send only productId + quantity — server fetches authoritative prices.
    final items =
        cartItems
            .map((e) => {'productId': e.productId, 'quantity': e.quantity})
            .toList();

    try {
      final idempotencyKey = const Uuid().v4();
      final orderId = await OrderServices.createOrder(
        storeId: storeId,
        items: items,
        paymentMethod: paymentMethod.toLowerCase(),
        idempotencyKey: idempotencyKey,
        orderNote: note,
      );
      return orderId;
    } on FirebaseFunctionsException catch (e) {
      // Surface the server-provided message when available.
      throw CheckoutException(e.message ?? 'Failed to place order.');
    }
  }
}
