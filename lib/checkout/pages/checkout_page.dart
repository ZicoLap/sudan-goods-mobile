import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/core/utils/delivery_fee_helper.dart';
import 'package:sudan_goods/models/shared_models/address.dart';

import 'package:sudan_goods/models/store/store_model.dart' ;

import 'package:sudan_goods/checkout/pages/payment_method_page.dart';
import 'package:sudan_goods/order/order_success_page.dart';
import 'sections/checkout_user_info_section.dart';
import 'sections/checkout_address_section.dart';
import 'sections/checkout_note_section.dart';
import 'sections/checkout_payment_section.dart';
import 'sections/checkout_store_section.dart';
import 'sections/checkout_summary_section.dart';

import 'package:sudan_goods/models/store/order_model.dart' as order_model;


class CheckoutPage extends StatefulWidget {
  final Store store;
  final double subtotal;
  final double totalWeight;

  const CheckoutPage({
    super.key,
    required this.store,
    required this.subtotal,
    required this.totalWeight,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedPaymentMethod = "Card";
  final TextEditingController noteController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }
Future<void> _placeOrder() async {





final user = FirebaseAuth.instance.currentUser;
final uid = user?.uid;
if (uid == null) {
  _showError("User not authenticated.");
  return;
}



final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

if (!userDoc.exists) {
  _showError("User data not found.");
  return;
}

final userData = userDoc.data()!;
final name = "${userData['firstName']} ${userData['lastName']}";
final phone = userData['phoneNumber'];
final List addressesJson = userData['addresses'] ?? [];

if (addressesJson.isEmpty) {
  _showError("No delivery address found.");
  return;
}

final address = Address.fromJson(addressesJson.first);

  final cartController = Provider.of<CartController>(context, listen: false);

  final cartItems = cartController.getItemsByStore(widget.store.id);
  final subtotal = cartController.getSubtotal(widget.store.id);
  final totalWeight = cartController.getTotalWeight(widget.store.id);
  final deliveryFee =  calculateDeliveryFee(
  store: widget.store,
  totalWeight: totalWeight,
  subtotal: subtotal,
);
  final total = subtotal + deliveryFee;

  if (cartItems.isEmpty) {
    _showError('Your cart is empty.');
    return;
  }


  setState(() => isLoading = true);

  try {
    final order = order_model.Order(
      userId: user!.uid,
      storeId: widget.store.id,
      items: cartItems,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      totalWeight: totalWeight,
      status: 'pending',
      paymentStatus: 'paid',
      paymentMethod: selectedPaymentMethod.toLowerCase(),
      name: name,
      phone: phone,
      address: address,
      orderNote: noteController.text,
      createdAt: Timestamp.fromDate(DateTime.now()),
      updatedAt: Timestamp.fromDate(DateTime.now()),
    );

    await FirebaseFirestore.instance.collection('orders').add(order.toJson());

    cartController.clearCart(widget.store.id);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OrderSuccessPage()),
        (route) => false,
      );
    }
  } catch (e) {
    _showError('Failed to place order. Please try again.');
  } finally {
    if (mounted) setState(() => isLoading = false);
  }
}

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _updatePaymentMethod(String method) {
    setState(() {
      selectedPaymentMethod = method;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CheckoutUserInfoSection(),
            const CheckoutAddressSection(),
            CheckoutNoteSection(controller: noteController),
            CheckoutPaymentSection(
              selectedMethod: selectedPaymentMethod,
              onTap: () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentMethodPage()),
                );
                if (result != null) _updatePaymentMethod(result);
              },
            ),
            CheckoutStoreSection(storeId: widget.store.id),
            CheckoutSummarySection(
              store: widget.store,
              subtotal: widget.subtotal,
              totalWeight: widget.totalWeight,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _placeOrder,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Place Order'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
