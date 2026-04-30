// ✅ lib/domains/customer/checkout/sections/checkout_summary_section.dart
import 'package:flutter/material.dart';
import 'package:sudan_goods/core/utils/delivery_fee_helper.dart';
import 'package:sudan_goods/models/store/store_model.dart';

class CheckoutSummarySection extends StatelessWidget {
  final Store store;
  final double subtotal;
  final double totalWeight;

  const CheckoutSummarySection({
    super.key,
    required this.store,
    required this.subtotal,
    required this.totalWeight,
  });

  @override
  Widget build(BuildContext context) {
    final deliveryFee = calculateDeliveryFee(
      store: store,
      subtotal: subtotal,
      totalWeight: totalWeight,
    );
    final total = subtotal + deliveryFee;

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
          const Text(
            "Estimated Order Summary",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            "Final total will be calculated at checkout",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          _buildPriceRow("Subtotal", subtotal),
          _buildPriceRow("Delivery Fee", deliveryFee),
          const Divider(height: 24),
          _buildPriceRow("Total", total, isBold: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "€${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
