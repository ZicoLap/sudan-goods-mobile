// ✅ lib/domains/customer/checkout/sections/checkout_store_section.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:provider/provider.dart';

class CheckoutStoreSection extends StatefulWidget {
  final String storeId;
  const CheckoutStoreSection({super.key, required this.storeId});

  @override
  State<CheckoutStoreSection> createState() => _CheckoutStoreSectionState();
}

class _CheckoutStoreSectionState extends State<CheckoutStoreSection> {
  String? storeName;
  String? storeLogoUrl;
  int itemCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStoreDetails();
  }

  Future<void> _loadStoreDetails() async {
    final doc = await FirebaseFirestore.instance.collection('stores').doc(widget.storeId).get();
    final data = doc.data();
    if (data != null) {
      final cart = Provider.of<CartController>(context, listen: false);
      setState(() {
        storeName = data['name'];
        storeLogoUrl = data['logoUrl'];
        itemCount = cart.getItemsByStore(widget.storeId).length;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        : Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                if (storeLogoUrl != null)
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(storeLogoUrl!),
                    backgroundColor: Colors.grey.shade200,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(storeName ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text("$itemCount items", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
