
import 'package:flutter/material.dart';
import 'package:sudan_goods/models/store/store_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class StoreInfoSection extends StatelessWidget {
  final Store store;
  const StoreInfoSection({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space20,
        vertical: DesignTokens.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store name and button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  store.name,
                  style: AppTypography.heading5,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Follow/unfollow logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.space16,
                    vertical: DesignTokens.space8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '+ Follow',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space8),

          // Description
          if (store.description != null && store.description!.isNotEmpty)
            Text(
              store.description!,
              style: AppTypography.body,
            ),

          const SizedBox(height: DesignTokens.space12),

          // Min order and rating
          Row(
            children: [
              _MetaChip(
                icon: Icons.shopping_basket,
                iconColor: Colors.green,
                label: 'Min. €${store.minimumOrderAmount.toStringAsFixed(0)}',
              ),
              const SizedBox(width: DesignTokens.space12),
              _MetaChip(
                icon: Icons.star,
                iconColor: Colors.amber,
                label: '${store.rating.toStringAsFixed(1)} (${store.ratingCount})',
              ),
            ],
          ),

          const SizedBox(height: DesignTokens.space12),

          // Location
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 18),
              const SizedBox(width: DesignTokens.space8),
              Text(
                '${store.address.country} / ${store.address.city}',
                style: AppTypography.small,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  const _MetaChip({required this.icon, required this.iconColor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space12,
        vertical: DesignTokens.space8,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: DesignTokens.space8),
          Text(label, style: AppTypography.small),
        ],
      ),
    );
  }
}
