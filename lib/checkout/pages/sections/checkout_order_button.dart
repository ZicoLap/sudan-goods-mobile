// ✅ lib/domains/customer/checkout/sections/checkout_order_button.dart
import 'package:flutter/material.dart';

class CheckoutOrderButton extends StatelessWidget {
  const CheckoutOrderButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade700,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text("Order and Pay", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }


}
