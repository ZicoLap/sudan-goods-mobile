import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudan_goods/models/store/order_model.dart' as order_model;

class OrderServices {
  static final _firestore = FirebaseFirestore.instance;
  static final _ordersRef = _firestore.collection('orders');

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
