
// ✅ lib/domains/customer/checkout/sections/checkout_summary_section.dart
import 'package:flutter/material.dart';

class CheckoutSummarySection extends StatelessWidget {
  const CheckoutSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SizedBox(height: 24),
        Text("Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Text("Subtotal: €0.00"),
        Text("Delivery: €0.00"),
        Divider(),
        Text("Total: €0.00", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
      ],
    );
  }
}