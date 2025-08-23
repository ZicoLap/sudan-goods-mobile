import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/checkout/controller/checkout_controller.dart';

import 'package:sudan_goods/models/store/store_model.dart';

import 'package:sudan_goods/checkout/pages/payment_method_page.dart';
import 'sections/checkout_user_info_section.dart';
import 'sections/checkout_address_section.dart';
import 'sections/checkout_note_section.dart';
import 'sections/checkout_payment_section.dart';
import 'sections/checkout_store_section.dart';
import 'sections/checkout_summary_section.dart';

/// Checkout screen that reviews the order, captures payment method and note,
/// and places an order for a specific [Store].
///
/// Requires the [store], current [subtotal], and [totalWeight] which are used
/// to calculate delivery fee and total at the time of placing the order.
class CheckoutPage extends StatefulWidget {
  final Store store;
  final double subtotal;
  final double totalWeight;

  /// Creates a [CheckoutPage] bound to a particular [store].
  const CheckoutPage({
    super.key,
    required this.store,
    required this.subtotal,
    required this.totalWeight,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

/// State for [CheckoutPage] managing local UI state like payment method,
/// note input, and loading indicator.
class _CheckoutPageState extends State<CheckoutPage> {
  String selectedPaymentMethod = "Card";
  final TextEditingController noteController = TextEditingController();

  @override
  /// Disposes text controllers to avoid memory leaks.
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  /// Delegates place-order to [CheckoutController] for business logic.
  Future<void> _placeOrder() async {
    await context.read<CheckoutController>().placeOrderViaService(
          context,
          store: widget.store,
          note: noteController.text,
          paymentMethod: selectedPaymentMethod,
        );
  }

  // Error toasts are handled by CheckoutController.

  /// Updates the selected payment method and rebuilds the UI.
  void _updatePaymentMethod(String method) {
    setState(() {
      selectedPaymentMethod = method;
    });
  }

  @override
  /// Builds the checkout UI composed of user info, address, note, payment,
  /// store items, and order summary sections, with a primary action button to
  /// place the order.
  Widget build(BuildContext context) {
    final isLoading = context.watch<CheckoutController>().isLoading;
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
                child:
                    isLoading
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
