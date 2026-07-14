import 'package:flutter/material.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/order/models/order_filter.dart';
import 'package:sudan_goods/order/utils/order_filter_utils.dart';
import 'package:sudan_goods/theme/app_theme.dart';

/// Horizontal toolbar: Filter | Date | Sort (matches Home [StoreFilterBar] style).
class OrderFilterBar extends StatelessWidget {
  const OrderFilterBar({
    super.key,
    required this.filter,
    required this.loading,
    required this.onOpenFilters,
    required this.onOpenDate,
    required this.onSortChanged,
  });

  final OrderFilter filter;
  final bool loading;
  final VoidCallback onOpenFilters;
  final VoidCallback onOpenDate;
  final ValueChanged<OrderSortOption> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateLabel =
        filter.hasDateFilter
            ? orderDateLabel(l10n, filter.datePreset)
            : l10n.orderFilterDate;
    final sortLabel =
        filter.hasCustomSort
            ? orderSortLabel(l10n, filter.sortBy)
            : l10n.orderFilterSort;

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 0),
        children: [
          _ToolbarButton(
            active: filter.hasFilterCriteria,
            icon: Icons.tune_rounded,
            label: l10n.filterButtonLabel,
            badge: filter.filterActiveCount,
            onTap: loading ? null : onOpenFilters,
          ),
          _ToolbarButton(
            active: filter.hasDateFilter,
            icon: Icons.calendar_today_outlined,
            label: dateLabel,
            onTap: loading ? null : onOpenDate,
          ),
          PopupMenuButton<OrderSortOption>(
            enabled: !loading,
            tooltip: l10n.orderFilterSort,
            onSelected: onSortChanged,
            itemBuilder: (context) {
              return OrderSortOption.values
                  .map(
                    (option) => PopupMenuItem<OrderSortOption>(
                      value: option,
                      child: Row(
                        children: [
                          if (filter.sortBy == option)
                            const Icon(
                              Icons.check,
                              size: 18,
                              color: AppColors.primary,
                            )
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              orderSortLabel(l10n, option),
                              style: TextStyle(
                                fontWeight:
                                    filter.sortBy == option
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                color:
                                    filter.sortBy == option
                                        ? AppColors.primary
                                        : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList();
            },
            child: _ToolbarButtonShell(
              active: filter.hasCustomSort,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sort_rounded,
                    size: 15,
                    color:
                        filter.hasCustomSort ? Colors.white : Colors.black54,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    sortLabel,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color:
                          filter.hasCustomSort ? Colors.white : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: _ToolbarButtonShell(
          active: active,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: active ? Colors.white : Colors.black54,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : Colors.black54,
                ),
              ),
              if (badge != null && badge! > 0) ...[
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
                    '$badge',
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
    );
  }
}

class _ToolbarButtonShell extends StatelessWidget {
  const _ToolbarButtonShell({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              active ? AppColors.primary : Colors.black.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
