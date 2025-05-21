
// ✅ lib/domains/customer/checkout/sections/payment_method_page.dart
import 'package:flutter/material.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String? selected;

  final methods = [
    {'label': 'Apple Pay', 'icon': Icons.phone_iphone},
    {'label': 'Card', 'icon': Icons.credit_card},
    {'label': 'Google Pay', 'icon': Icons.android},
    {'label': 'Klarna', 'icon': Icons.account_balance_wallet},
    {'label': 'Sofort', 'icon': Icons.account_balance},
    {'label': 'Giropay', 'icon': Icons.payment},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(title: const Text("Select payment method"), centerTitle: true,),
        body: Column(
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Payment methods", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: methods.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final method = methods[index];
                  final isSelected = selected == method['label'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selected = method['label']! as String?;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: isSelected ? Colors.orange : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(method['icon'] as IconData, size: 28),
                          const SizedBox(width: 16),
                          Expanded(child: Text(method['label'] as String, style: const TextStyle(fontSize: 16))),
                          if (isSelected) const Icon(Icons.check_circle, color: Colors.orange),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selected == null ? null : () => Navigator.pop(context, selected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Confirm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
