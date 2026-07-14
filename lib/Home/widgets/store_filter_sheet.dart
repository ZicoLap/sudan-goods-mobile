import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/home/controllers/store_filter_controller.dart';
import 'package:sudan_goods/home/models/store_filter.dart';
import 'package:sudan_goods/home/services/store_service.dart';
import 'package:sudan_goods/home/widgets/filter_chip_group.dart';
import 'package:sudan_goods/home/widgets/filter_section.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/models/store/store_model.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

/// Full-screen bottom sheet for editing store filters.
///
/// Keeps a temporary copy of the filter while the user is interacting,
/// then commits the result to the controller when Apply is pressed.
class StoreFilterSheet extends StatefulWidget {
  const StoreFilterSheet({super.key});

  @override
  State<StoreFilterSheet> createState() => _StoreFilterSheetState();
}

class _StoreFilterSheetState extends State<StoreFilterSheet> {
  late StoreFilter _draft;

  static const _minOrderOptions = [
    FilterChipData(key: 'any', label: 'Any'),
    FilterChipData(key: '10', label: '≤ €10'),
    FilterChipData(key: '20', label: '≤ €20'),
    FilterChipData(key: '50', label: '≤ €50'),
    FilterChipData(key: '100', label: '≤ €100'),
  ];

  @override
  void initState() {
    super.initState();
    _draft = context.read<StoreFilterController>().filter;
  }

  void _commit() {
    final controller = context.read<StoreFilterController>();

    // Sync numeric criterion.
    controller.setMaxMinOrder(_draft.maxMinOrder);

    // Sync country selection.
    controller.selectCountry(_draft.selectedCountry);

    // Sync boolean criteria. The controller's toggle methods flip the current
    // value, so we call them only when the draft differs from the controller.
    if (_draft.openNow != controller.filter.openNow) {
      controller.toggleOpenNow();
    }
    if (_draft.featured != controller.filter.featured) {
      controller.toggleFeatured();
    }
    if (_draft.freeDelivery != controller.filter.freeDelivery) {
      controller.toggleFreeDelivery();
    }

    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _draft = StoreFilter(selectedCategoryId: _draft.selectedCategoryId);
    });
  }

  String _minOrderLabel() {
    final value = _draft.maxMinOrder;
    if (value == null || value <= 0) return 'Any';
    return '≤ €${value.toInt()}';
  }

  double _minOrderValue() {
    final value = _draft.maxMinOrder;
    if (value == null || value <= 0) return 0;
    return value;
  }

  void _onMinOrderSliderChanged(double value) {
    setState(() {
      _draft = _draft.copyWith(maxMinOrder: value == 0 ? null : value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle.
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFFD05000)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.filterSheetTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _reset,
                  child: Text(
                    l10n.filterReset,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 20),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country.
                  FilterSection(
                    icon: Icons.public_rounded,
                    title: l10n.filterCountry,
                    iconColor: Colors.blue,
                    child: StreamBuilder<List<Store>>(
                      stream: StoreServices().streamAllApprovedStores(),
                      builder: (context, snapshot) {
                        final stores = snapshot.data ?? [];
                        final countries =
                            <String>{
                                ...stores.map((s) => s.address.country),
                              }.where((c) => c.isNotEmpty).toList()
                              ..sort();

                        final countryChips = [
                          FilterChipData(
                            key: 'all',
                            label: l10n.filterCountryAny,
                          ),
                          ...countries.map(
                            (c) => FilterChipData(key: c, label: c),
                          ),
                        ];

                        return FilterChipGroup(
                          chips: countryChips,
                          selectedKeys: {_draft.selectedCountry ?? 'all'},
                          onSelected: (key) {
                            setState(() {
                              _draft = _draft.copyWith(
                                selectedCountry: key == 'all' ? null : key,
                                clearSelectedCountry: key == 'all',
                              );
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Open Now.
                  FilterSection(
                    icon: Icons.access_time_rounded,
                    title: l10n.filterOpenNow,
                    iconColor: Colors.green,
                    child: _BooleanToggle(
                      value: _draft.openNow,
                      label: l10n.filterOpenNowSubtitle,
                      onChanged:
                          (v) => setState(
                            () => _draft = _draft.copyWith(openNow: v),
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Featured.
                  FilterSection(
                    icon: Icons.star_outline_rounded,
                    title: l10n.filterFeatured,
                    iconColor: Colors.amber,
                    child: _BooleanToggle(
                      value: _draft.featured,
                      label: l10n.filterFeaturedSubtitle,
                      onChanged:
                          (v) => setState(
                            () => _draft = _draft.copyWith(featured: v),
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Free Delivery.
                  FilterSection(
                    icon: Icons.local_shipping_outlined,
                    title: l10n.filterFreeDelivery,
                    iconColor: Colors.deepOrange,
                    child: _BooleanToggle(
                      value: _draft.freeDelivery,
                      label: l10n.filterFreeDeliverySubtitle,
                      onChanged:
                          (v) => setState(
                            () => _draft = _draft.copyWith(freeDelivery: v),
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Minimum Order.
                  FilterSection(
                    icon: Icons.payments_rounded,
                    title: l10n.filterMinOrder,
                    iconColor: Colors.blue,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppColors.primary,
                                  thumbColor: AppColors.primary,
                                  inactiveTrackColor: AppColors.primary
                                      .withValues(alpha: 0.15),
                                  overlayColor: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  trackHeight: 4,
                                ),
                                child: Slider(
                                  value: _minOrderValue(),
                                  min: 0,
                                  max: 100,
                                  divisions: 10,
                                  onChanged: _onMinOrderSliderChanged,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _minOrderLabel(),
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        FilterChipGroup(
                          chips: _minOrderOptions,
                          selectedKeys: {
                            if (_draft.maxMinOrder == null) 'any',
                            if (_draft.maxMinOrder == 10) '10',
                            if (_draft.maxMinOrder == 20) '20',
                            if (_draft.maxMinOrder == 50) '50',
                            if (_draft.maxMinOrder == 100) '100',
                          },
                          onSelected: (key) {
                            setState(() {
                              _draft = _draft.copyWith(
                                maxMinOrder:
                                    key == 'any' ? null : double.parse(key),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Apply button.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: SizedBox(
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFFD05000)],
                  ),
                  borderRadius: BorderRadius.circular(
                    DesignTokens.radiusXLarge,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _commit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusXLarge,
                      ),
                    ),
                  ),
                  child: Text(
                    l10n.filterApply,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single-row toggle used inside the filter sheet for boolean criteria.
class _BooleanToggle extends StatelessWidget {
  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  const _BooleanToggle({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                value
                    ? AppColors.primary
                    : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: value ? Colors.white : Colors.black87,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                value ? Icons.check_circle_rounded : Icons.circle_outlined,
                key: ValueKey(value),
                color: value ? Colors.white : Colors.black26,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
