// ✅ lib/domains/customer/checkout/sections/checkout_user_info_section.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/user/user_provider.dart';
import '../sheets/edit_user_info_sheet.dart';

class CheckoutUserInfoSection extends StatefulWidget {
  const CheckoutUserInfoSection({super.key});

  @override
  State<CheckoutUserInfoSection> createState() => _CheckoutUserInfoSectionState();
}

class _CheckoutUserInfoSectionState extends State<CheckoutUserInfoSection> {
  bool _triggeredFetch = false;

  @override
  void initState() {
    super.initState();
    // Ensure user is loaded into UserProvider once.
    // This keeps UI free from direct Firestore access.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProv = context.read<UserProvider>();
      if (!userProv.isUserLoaded && !_triggeredFetch) {
        _triggeredFetch = true;
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          try {
            await userProv.fetchUser(uid);
          } catch (_) {
            // Ignore here; controller layer will surface errors if needed.
          }
        }
      }
    });
  }

  Future<void> _editUserInfo() async {
    final userProv = context.read<UserProvider>();
    final isLoaded = userProv.isUserLoaded;
    final currentFirst = isLoaded ? userProv.currentUser.firstName : '';
    final currentLast = isLoaded ? userProv.currentUser.lastName : '';
    final currentPhone = isLoaded ? userProv.currentUser.phoneNumber : '';
    final updated = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditUserInfoSheet(
        firstName: currentFirst,
        lastName: currentLast,
        phone: currentPhone,
      ),
    );

    if (updated != null) {
      await userProv.updateUserProfile(
        firstName: updated['firstName'],
        lastName: updated['lastName'],
        phoneNumber: updated['phone'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    if (!userProv.isUserLoaded) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final user = userProv.currentUser;
    return GestureDetector(
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
                  Text("${user.firstName} ${user.lastName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(user.phoneNumber, style: const TextStyle(fontSize: 14, color: Colors.grey)),
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