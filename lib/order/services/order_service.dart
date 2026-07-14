import 'package:cloud_functions/cloud_functions.dart';

/// Service for creating orders via the backend Cloud Function.
///
/// All pricing, validation, and document creation happens server-side.
/// The client only sends minimal input (storeId, item IDs + quantities).
class OrderServices {
  static final _functions = FirebaseFunctions.instance;

  /// Places an order by calling the `createOrder` Cloud Function.
  ///
  /// An [idempotencyKey] should be generated once per checkout attempt to
  /// prevent duplicate orders on retries or double-taps.
  ///
  /// Returns the Firestore-generated order ID on success.
  /// Throws [FirebaseFunctionsException] on failure so callers can surface
  /// user-friendly messages.
  static Future<String> createOrder({
    required String storeId,
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    required String idempotencyKey,
    String? orderNote,
  }) async {
    final callable = _functions.httpsCallable('createOrder');

    final response = await callable.call(<String, dynamic>{
      'storeId': storeId,
      'items': items,
      'paymentMethod': paymentMethod,
      'idempotencyKey': idempotencyKey,
      if (orderNote != null && orderNote.isNotEmpty) 'orderNote': orderNote,
    });

    final data = response.data as Map<String, dynamic>;
    return data['orderId'] as String;
  }
}
