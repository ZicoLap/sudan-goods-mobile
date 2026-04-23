import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/core/utils/delivery_fee_helper.dart';
import 'package:sudan_goods/models/shared_models/address.dart';
import 'package:sudan_goods/models/store/order_model.dart' as order_model;
import 'package:sudan_goods/models/store/store_model.dart';
import 'package:sudan_goods/order/order_service.dart';
import 'package:sudan_goods/checkout/services/payment_gateway.dart';
import 'package:sudan_goods/authentication/user/user_provider.dart';

/// Lightweight domain error for checkout failures.
class CheckoutException implements Exception {
  final String message;
  CheckoutException(this.message);
  @override
  String toString() => 'CheckoutException: $message';
}

/// Service that orchestrates checkout operations:
/// - Reads user profile and address
/// - Reads cart state
/// - Computes delivery fee and totals
/// - Builds and persists Order via OrderServices
///
/// Note: Payment is intentionally not implemented. A payment gateway can be
/// injected here in the future (e.g., Stripe) before creating the order.
class CheckoutService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final PaymentGateway? paymentGateway;

  CheckoutService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    this.paymentGateway,
  })
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  /// Builds an Order from current app state. Throws [CheckoutException]
  /// with a user-friendly message on validation or data issues.
  Future<order_model.Order> buildOrder(
    BuildContext context, {
    required Store store,
    required String note,
    required String selectedPaymentMethod,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw CheckoutException('User not authenticated.');
    }

    // Prefer UserProvider as the source of truth; fallback to Firestore.
    String? firstName;
    String? lastName;
    String? phone;
    List<Address>? addresses;

    final userProv = Provider.of<UserProvider>(context, listen: false);
    if (userProv.isUserLoaded) {
      firstName = userProv.currentUser.firstName;
      lastName = userProv.currentUser.lastName;
      phone = userProv.currentUser.phoneNumber;
      addresses = userProv.currentUser.addresses;
    }

    if (firstName == null || lastName == null || phone == null || (addresses == null || addresses.isEmpty)) {
      final userDoc = await _db.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw CheckoutException('User data not found.');
      }
      final data = userDoc.data()!;
      firstName = firstName ?? (data['firstName'] as String?);
      lastName = lastName ?? (data['lastName'] as String?);
      phone = phone ?? (data['phoneNumber'] as String? ?? '');
      final List addressesJson = data['addresses'] ?? [];
      if (addresses == null || addresses.isEmpty) {
        if (addressesJson.isEmpty) {
          throw CheckoutException('No delivery address found.');
        }
        addresses = [Address.fromJson(addressesJson.first)];
      }
    }

    final Address address = addresses.first;
    final String name = '${firstName ?? ''} ${lastName ?? ''}'.trim();

    final cart = Provider.of<CartController>(context, listen: false);
    final items = cart.getItemsByStore(store.id);
    if (items.isEmpty) {
      throw CheckoutException('Your cart is empty.');
    }

    final double subtotal = cart.getSubtotal(store.id);
    final double totalWeight = cart.getTotalWeight(store.id);
    final double deliveryFee = calculateDeliveryFee(
      store: store,
      subtotal: subtotal,
      totalWeight: totalWeight,
    );
    final double total = subtotal + deliveryFee;

    // Determine payment status. If a gateway is injected, attempt to
    // confirm the payment before creating the order.
    String paymentStatus = 'paid'; // default for no-gateway (mock flow)
    if (paymentGateway != null) {
      final amountInMinorUnits = (total * 100).round();
      final result = await paymentGateway!.confirmPayment(
        amountInMinorUnits: amountInMinorUnits,
        currency: 'USD',
        description: 'Order for ${store.name}',
        metadata: {
          'userId': user.uid,
          'storeId': store.id,
          'paymentMethod': selectedPaymentMethod.toLowerCase(),
        },
      );

      if (!result.success) {
        throw CheckoutException(result.errorMessage ?? 'Payment failed.');
      }

      paymentStatus = 'paid';
    }

    return order_model.Order(
      userId: user.uid,
      storeId: store.id,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      totalWeight: totalWeight,
      status: 'pending',
      // Payment integration hook: determined above via optional gateway.
      paymentStatus: paymentStatus,
      paymentMethod: selectedPaymentMethod.toLowerCase(),
      name: name,
      phone: phone,
      address: address,
      orderNote: note,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );
  }

  /// Persists the order using the existing OrderServices.
  Future<void> createOrder(order_model.Order order) async {
    await OrderServices.createOrder(order);
  }
}
