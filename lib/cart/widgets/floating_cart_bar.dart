import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/cart/widgets/cart_bottom_sheet_widget.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

class _CartSnapshot {
  final int count;
  final double subtotal;
  const _CartSnapshot(this.count, this.subtotal);
}

class FloatingCartBar extends StatelessWidget {
  final String storeId; // ✅ Must be passed from StoreDetailsPage

  const FloatingCartBar({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Selector<CartController, _CartSnapshot>(
      selector: (_, c) {
        final items = c.getItemsByStore(storeId);
        final count = items.fold<int>(0, (sum, it) => sum + it.quantity);
        final subtotal = c.getSubtotal(storeId);
        return _CartSnapshot(count, subtotal);
      },
      builder: (context, snap, _) {
        if (snap.count == 0) return const SizedBox.shrink();
        return InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => CartBottomSheet(storeId: storeId),
            );
          },
          child: Container(
            height: 64,
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
              boxShadow: DesignTokens.shadowLarge,
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 28),
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: DesignTokens.shadowSmall,
                        ),
                        child: Text(
                          '${snap.count}',
                          style: AppTypography.captionBold.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: DesignTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.viewCart, style: AppTypography.bodyBold.copyWith(color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(
                        '${l10n.total} €${snap.subtotal.toStringAsFixed(2)}',
                        style: AppTypography.small.copyWith(color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}
