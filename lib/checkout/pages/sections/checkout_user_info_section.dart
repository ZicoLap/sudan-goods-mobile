// ✅ lib/domains/customer/checkout/sections/checkout_user_info_section.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../sheets/edit_user_info_sheet.dart';

class CheckoutUserInfoSection extends StatefulWidget {
  const CheckoutUserInfoSection({super.key});

  @override
  State<CheckoutUserInfoSection> createState() => _CheckoutUserInfoSectionState();
}

class _CheckoutUserInfoSectionState extends State<CheckoutUserInfoSection> {
  String? firstName;
  String? lastName;
  String? phone;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          firstName = data['firstName'];
          lastName = data['lastName'];
          phone = data['phoneNumber'];
          isLoading = false;
        });
      }
    }
  }

  Future<void> _editUserInfo() async {
    final updated = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditUserInfoSheet(
        firstName: firstName ?? '',
        lastName: lastName ?? '',
        phone: phone ?? '',
      ),
    );

    if (updated != null) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'firstName': updated['firstName'],
          'lastName': updated['lastName'],
          'phoneNumber': updated['phone'],
        });
        _fetchUserInfo();
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
            onTap: _editUserInfo,
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
                  const Icon(Icons.person_outline, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$firstName $lastName", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(phone ?? '', style: const TextStyle(fontSize: 14, color: Colors.grey)),
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