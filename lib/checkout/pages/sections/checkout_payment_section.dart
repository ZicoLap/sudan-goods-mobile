
// ✅ lib/domains/customer/checkout/sections/checkout_payment_section.dart
import 'package:flutter/material.dart';

class CheckoutPaymentSection extends StatelessWidget {
  final String selectedMethod;
  final VoidCallback onTap;

  const CheckoutPaymentSection({
    super.key,
    required this.selectedMethod,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.payment, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(selectedMethod, style: const TextStyle(fontSize: 16)),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}