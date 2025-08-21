import 'package:flutter/material.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class StoreCartCard extends StatelessWidget {
  final String storeId;
  final String storeName;
  final String? storeLogoUrl;
  final int itemCount;
  final double subtotal;
  final VoidCallback onTap;
  final VoidCallback onCheckout;

  const StoreCartCard({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.itemCount,
    required this.subtotal,
    required this.onTap,
    required this.onCheckout,
    this.storeLogoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignTokens.space12),
        padding: DesignTokens.paddingCard,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          boxShadow: DesignTokens.shadowMedium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                storeLogoUrl != null && storeLogoUrl!.isNotEmpty
                    ? CircleAvatar(radius: 20, backgroundImage: NetworkImage(storeLogoUrl!))
                    : const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.store_rounded, color: Colors.white),
                      ),
                const SizedBox(width: DesignTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(storeName, style: AppTypography.cardTitle),
                      Text('$itemCount items', style: AppTypography.small.copyWith(color: Colors.black54)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.black45),
              ],
            ),

            const SizedBox(height: DesignTokens.space16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: AppTypography.small.copyWith(color: Colors.black54)),
                Text('€${subtotal.toStringAsFixed(2)}', style: AppTypography.bodyBold),
              ],
            ),

            const SizedBox(height: DesignTokens.space16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCheckout,
                child: const Text('Checkout This Store'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
