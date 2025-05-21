
// ✅ lib/domains/customer/checkout/sections/checkout_shipping_section.dart
import 'package:flutter/material.dart';

class CheckoutShippingSection extends StatefulWidget {
  const CheckoutShippingSection({super.key});

  @override
  State<CheckoutShippingSection> createState() => _CheckoutShippingSectionState();
}

class _CheckoutShippingSectionState extends State<CheckoutShippingSection> {
  String selectedOption = "standard";

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.local_shipping_outlined, color: Colors.orange),
              SizedBox(width: 12),
              Text("Shipping Option", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          RadioListTile(
            value: "standard",
            groupValue: selectedOption,
            onChanged: (value) {
              setState(() {
                selectedOption = value.toString();
              });
            },
            title: const Text("Standard Delivery (Free, 2–3 days)"),
          ),
          RadioListTile(
            value: "express",
            groupValue: selectedOption,
            onChanged: (value) {
              setState(() {
                selectedOption = value.toString();
              });
            },
            title: const Text("Express Delivery (€5.00, 1 day)"),
          ),
        ],
      ),
    );
  }
}
