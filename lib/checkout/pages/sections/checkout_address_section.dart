// ✅ lib/domains/customer/checkout/sections/checkout_address_section.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/models/shared_models/address.dart';
import 'package:sudan_goods/authentication/user/user_provider.dart';

class CheckoutAddressSection extends StatefulWidget {
  const CheckoutAddressSection({super.key});

  @override
  State<CheckoutAddressSection> createState() => _CheckoutAddressSectionState();
}

class _CheckoutAddressSectionState extends State<CheckoutAddressSection> {
  bool _triggeredFetch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProv = context.read<UserProvider>();
      if (!userProv.isUserLoaded && !_triggeredFetch) {
        _triggeredFetch = true;
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          try {
            await userProv.fetchUser(uid);
          } catch (_) {
            // Suppress here; controller/UI can handle error presentation elsewhere
          }
        }
      }
    });
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

    final List<Address> addresses = userProv.currentUser.addresses;
    final hasAddress = addresses.isNotEmpty;
    final primary = hasAddress ? addresses.first : null;
    final street = primary?.street ?? 'No address found';
    final city = primary != null ? "${primary.postalCode} ${primary.city}" : '';

    return GestureDetector(
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
                    street,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    city,
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
