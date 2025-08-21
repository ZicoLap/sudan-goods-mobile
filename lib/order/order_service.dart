import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudan_goods/models/store/order_model.dart' as order_model;

/// Firestore-backed service for performing operations on orders.
///
/// Currently supports creating an order document in the `orders` collection.
class OrderServices {
  static final _firestore = FirebaseFirestore.instance;
  static final _ordersRef = _firestore.collection('orders');

  /// Persists a new [order] document in the `orders` collection.
  ///
  /// Throws on failure so callers can handle errors appropriately
  /// (e.g., surface a snackbar or retry logic).
  static Future<void> createOrder(order_model.Order order) async {
    try {
      final docRef = await _ordersRef.add(order.toJson());

      print('✅ Order placed successfully with ID: ${docRef.id}');
    } catch (e) {
      print('❌ Failed to place order: $e');
      rethrow;
    }
  }
}
