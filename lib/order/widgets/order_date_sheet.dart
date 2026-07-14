import 'package:flutter/material.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/order/models/order_filter.dart';
import 'package:sudan_goods/order/utils/order_filter_utils.dart';
import 'package:sudan_goods/theme/app_theme.dart';

/// Lightweight bottom sheet for choosing a date range preset.
class OrderDateSheet extends StatelessWidget {
  const OrderDateSheet({super.key, required this.selected});

  final DateRangePreset selected;

  static Future<DateRangePreset?> show(
    BuildContext context, {
    required DateRangePreset selected,
  }) {
    return showModalBottomSheet<DateRangePreset>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderDateSheet(selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Text(
              l10n.orderDateSheetTitle,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 4),
          ...DateRangePreset.values.map((preset) {
            return RadioListTile<DateRangePreset>(
              value: preset,
              groupValue: selected,
              activeColor: AppColors.primary,
              title: Text(
                orderDateLabel(l10n, preset),
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onChanged: (value) {
                if (value != null) Navigator.pop(context, value);
              },
            );
          }),
        ],
      ),
    );
  }
}
