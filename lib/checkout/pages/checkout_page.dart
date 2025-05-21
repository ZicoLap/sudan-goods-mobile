// ✅ lib/domains/customer/checkout/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:sudan_goods/checkout/pages/payment_method_page.dart';
import 'sections/checkout_user_info_section.dart';
import 'sections/checkout_address_section.dart';
import 'sections/checkout_note_section.dart';
import 'sections/checkout_shipping_section.dart';
import 'sections/checkout_payment_section.dart';
import 'sections/checkout_store_section.dart';
import 'sections/checkout_summary_section.dart';
import 'sections/checkout_order_button.dart';


class CheckoutPage extends StatefulWidget {
 final String storeId;
  const CheckoutPage({super.key, required this.storeId});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedPaymentMethod = "Card";

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
            const CheckoutNoteSection(),
            const CheckoutShippingSection(),
            CheckoutPaymentSection(
              selectedMethod: selectedPaymentMethod,
              onTap: () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentMethodPage(),
                  ),
                );
                if (result != null) _updatePaymentMethod(result);
              },
            ),
            CheckoutStoreSection(storeId: widget.storeId),
            const CheckoutSummarySection(),
            const CheckoutOrderButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
