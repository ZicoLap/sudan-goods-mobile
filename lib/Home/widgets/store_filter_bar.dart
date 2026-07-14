import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/Home/controller/store_filter_controller.dart';
import 'package:sudan_goods/Home/widgets/filter_chip_group.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/theme/app_theme.dart';

/// Horizontal filter bar shown below the Home hero header.
///
/// Provides one-tap toggles for the most common filters and a button
/// that opens the full filter sheet for advanced options.
class StoreFilterBar extends StatelessWidget {
  final VoidCallback onMoreFilters;

  const StoreFilterBar({super.key, required this.onMoreFilters});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StoreFilterController>();
    final filter = controller.filter;
    final l10n = AppLocalizations.of(context)!;

    final quickChips = [
      FilterChipData(
        key: 'openNow',
        label: l10n.filterOpenNow,
        icon: Icons.access_time_rounded,
      ),
      FilterChipData(
        key: 'featured',
        label: l10n.filterFeatured,
        icon: Icons.star_outline_rounded,
      ),
      FilterChipData(
        key: 'freeDelivery',
        label: l10n.filterFreeDelivery,
        icon: Icons.local_shipping_outlined,
      ),
    ];

    final selectedQuickFilters = <String>{
      if (filter.openNow) 'openNow',
      if (filter.featured) 'featured',
      if (filter.freeDelivery) 'freeDelivery',
    };

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 0),
        children: [
          // More filters button with active count badge.
          GestureDetector(
            onTap: onMoreFilters,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color:
                    controller.hasActiveFilters
                        ? AppColors.primary
                        : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      controller.hasActiveFilters
                          ? AppColors.primary
                          : Colors.black.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 15,
                    color:
                        controller.hasActiveFilters
                            ? Colors.white
                            : Colors.black54,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    l10n.filterButtonLabel,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color:
                          controller.hasActiveFilters
                              ? Colors.white
                              : Colors.black54,
                    ),
                  ),
                  if (controller.activeFilterCount > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${controller.activeFilterCount}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Quick toggle chips.
          FilterChipGroup(
            chips: quickChips,
            selectedKeys: selectedQuickFilters,
            onSelected: (key) {
              switch (key) {
                case 'openNow':
                  controller.toggleOpenNow();
                  break;
                case 'featured':
                  controller.toggleFeatured();
                  break;
                case 'freeDelivery':
                  controller.toggleFreeDelivery();
                  break;
              }
            },
          ),
        ],
      ),
    );
  }
}
