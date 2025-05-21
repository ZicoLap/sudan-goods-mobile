// ✅ lib/domains/customer/checkout/sections/checkout_address_section.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CheckoutAddressSection extends StatefulWidget {
  const CheckoutAddressSection({super.key});

  @override
  State<CheckoutAddressSection> createState() => _CheckoutAddressSectionState();
}

class _CheckoutAddressSectionState extends State<CheckoutAddressSection> {
  String? street;
  String? city;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserAddress();
  }

  Future<void> _fetchUserAddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null &&
          data['addresses'] != null &&
          data['addresses'].isNotEmpty) {
        final address = data['addresses'][0];
        setState(() {
          street = address['street'];
          city = "${address['postalCode']} ${address['city']}";
          isLoading = false;
        });
      } else {
        setState(() {
          street = "No address found";
          city = "";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        )
        : GestureDetector(
          onTap: () {
            // TODO: Show edit address bottom sheet
          },
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
                const Icon(Icons.location_on_outlined, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        street ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        city ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
  }
}
