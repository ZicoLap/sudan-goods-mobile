// ✅ lib/domains/customer/checkout/sections/checkout_user_info_section.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/user/user_provider.dart';
import '../sheets/edit_user_info_sheet.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:shimmer/shimmer.dart';

class CheckoutUserInfoSection extends StatefulWidget {
  const CheckoutUserInfoSection({super.key});

  @override
  State<CheckoutUserInfoSection> createState() => _CheckoutUserInfoSectionState();
}

class _CheckoutUserInfoSectionState extends State<CheckoutUserInfoSection> {
  bool _triggeredFetch = false;

  Widget _iconBubble(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.95),
            AppColors.primary.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: DesignTokens.shadowSmall,
      ),
      child: Center(child: Icon(icon, color: Colors.white, size: 20)),
    );
  }

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
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.radiusLarge),
          topRight: Radius.circular(DesignTokens.radiusLarge),
        ),
      ),
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
      return Container(
        margin: const EdgeInsets.only(bottom: DesignTokens.space12),
        padding: const EdgeInsets.all(DesignTokens.space16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: DesignTokens.shadowSmall,
        ),
        child: Row(
          children: [
            _iconBubble(Icons.person_outline),
            const SizedBox(width: DesignTokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 16,
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      );
    }

    final user = userProv.currentUser;
    return GestureDetector(
      onTap: _editUserInfo,
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignTokens.space12),
        padding: const EdgeInsets.all(DesignTokens.space16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: DesignTokens.shadowSmall,
        ),
        child: Row(
          children: [
            _iconBubble(Icons.person_outline),
            const SizedBox(width: DesignTokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${user.firstName} ${user.lastName}",
                    style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phoneNumber,
                    style: AppTypography.body.copyWith(color: Colors.grey[600]),
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