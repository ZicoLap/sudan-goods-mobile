import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sudan_goods/Home/widgets/filter_chip_group.dart';
import 'package:sudan_goods/Home/widgets/filter_section.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/order/models/order_filter.dart';
import 'package:sudan_goods/order/utils/order_filter_utils.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

/// Bottom sheet for filtering the user's orders list.
class OrderFilterSheet extends StatefulWidget {
  const OrderFilterSheet({
    super.key,
    required this.initialFilter,
    required this.storeOptions,
  });

  final OrderFilter initialFilter;
  final Map<String, String> storeOptions;

  static Future<OrderFilter?> show(
    BuildContext context, {
    required OrderFilter initialFilter,
    required Map<String, String> storeOptions,
  }) {
    return showModalBottomSheet<OrderFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => OrderFilterSheet(
            initialFilter: initialFilter,
            storeOptions: storeOptions,
          ),
    );
  }

  @override
  State<OrderFilterSheet> createState() => _OrderFilterSheetState();
}

class _OrderFilterSheetState extends State<OrderFilterSheet> {
  late OrderFilter _draft;

  static const _statusKeys = [
    'pending',
    'confirmed',
    'preparing',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
    'fulfillment_review',
  ];

  @override
  void initState() {
    super.initState();
    _draft = widget.initialFilter;
  }

  void _reset() => setState(() => _draft = OrderFilter.defaults());

  void _apply() => Navigator.pop(context, _draft);

  String _statusLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'pending':
        return l10n.orderStatusPending;
      case 'confirmed':
        return l10n.orderStatusConfirmed;
      case 'preparing':
        return l10n.orderStatusPreparing;
      case 'processing':
        return l10n.orderStatusProcessing;
      case 'shipped':
        return l10n.orderStatusShipped;
      case 'delivered':
        return l10n.orderStatusDelivered;
      case 'cancelled':
        return l10n.orderStatusCancelled;
      case 'fulfillment_review':
        return l10n.orderStatusFulfillmentReview;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final storeEntries =
        widget.storeOptions.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
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
                  l10n.orderFilterSheetTitle,
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
                  FilterSection(
                    icon: Icons.local_offer_outlined,
                    title: l10n.orderStatusLabel,
                    iconColor: AppColors.primary,
                    child: FilterChipGroup(
                      chips:
                          _statusKeys
                              .map(
                                (key) => FilterChipData(
                                  key: key,
                                  label: _statusLabel(l10n, key),
                                ),
                              )
                              .toList(),
                      selectedKeys: _draft.statuses,
                      onSelected: (key) {
                        setState(() {
                          final next = Set<String>.from(_draft.statuses);
                          if (next.contains(key)) {
                            next.remove(key);
                          } else {
                            next.add(key);
                          }
                          _draft = _draft.copyWith(statuses: next);
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilterSection(
                    icon: Icons.storefront_outlined,
                    title: l10n.orderFilterStore,
                    iconColor: Colors.blue,
                    child: FilterChipGroup(
                      chips: [
                        FilterChipData(
                          key: 'all',
                          label: l10n.orderFilterStoreAny,
                        ),
                        ...storeEntries.map(
                          (e) => FilterChipData(key: e.key, label: e.value),
                        ),
                      ],
                      selectedKeys: {_draft.storeId ?? 'all'},
                      onSelected: (key) {
                        setState(() {
                          _draft = _draft.copyWith(
                            storeId: key == 'all' ? null : key,
                            clearStoreId: key == 'all',
                          );
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilterSection(
                    icon: Icons.euro_rounded,
                    title: l10n.orderFilterAmount,
                    iconColor: Colors.green,
                    child: FilterChipGroup(
                      chips: [
                        FilterChipData(
                          key: AmountRangePreset.any.name,
                          label: l10n.orderFilterAmountAny,
                        ),
                        FilterChipData(
                          key: AmountRangePreset.under25.name,
                          label: l10n.orderFilterAmountUnder25,
                        ),
                        FilterChipData(
                          key: AmountRangePreset.from25to50.name,
                          label: l10n.orderFilterAmount25to50,
                        ),
                        FilterChipData(
                          key: AmountRangePreset.from50to100.name,
                          label: l10n.orderFilterAmount50to100,
                        ),
                        FilterChipData(
                          key: AmountRangePreset.over100.name,
                          label: l10n.orderFilterAmountOver100,
                        ),
                      ],
                      selectedKeys: {_draft.amountPreset.name},
                      onSelected:
                          (key) => setState(() {
                            _draft = _draft.copyWith(
                              amountPreset: AmountRangePreset.values.byName(
                                key,
                              ),
                            );
                          }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilterSection(
                    icon: Icons.calendar_today_outlined,
                    title: l10n.orderFilterDate,
                    iconColor: Colors.teal,
                    child: FilterChipGroup(
                      chips: [
                        FilterChipData(
                          key: DateRangePreset.allTime.name,
                          label: l10n.orderFilterDateAllTime,
                        ),
                        FilterChipData(
                          key: DateRangePreset.last7Days.name,
                          label: l10n.orderFilterDateLast7Days,
                        ),
                        FilterChipData(
                          key: DateRangePreset.last30Days.name,
                          label: l10n.orderFilterDateLast30Days,
                        ),
                        FilterChipData(
                          key: DateRangePreset.last3Months.name,
                          label: l10n.orderFilterDateLast3Months,
                        ),
                      ],
                      selectedKeys: {_draft.datePreset.name},
                      onSelected:
                          (key) => setState(() {
                            _draft = _draft.copyWith(
                              datePreset: DateRangePreset.values.byName(key),
                            );
                          }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilterSection(
                    icon: Icons.payments_outlined,
                    title: l10n.orderFilterPayment,
                    iconColor: Colors.indigo,
                    child: FilterChipGroup(
                      chips: [
                        FilterChipData(
                          key: 'any',
                          label: l10n.orderFilterPaymentAny,
                        ),
                        FilterChipData(
                          key: 'paid',
                          label: l10n.orderFilterPaymentPaid,
                        ),
                        FilterChipData(
                          key: 'unpaid',
                          label: l10n.orderFilterPaymentUnpaid,
                        ),
                      ],
                      selectedKeys: {_draft.paymentStatus ?? 'any'},
                      onSelected: (key) {
                        setState(() {
                          _draft = _draft.copyWith(
                            paymentStatus: key == 'any' ? null : key,
                            clearPaymentStatus: key == 'any',
                          );
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilterSection(
                    icon: Icons.sort_rounded,
                    title: l10n.orderFilterSort,
                    iconColor: Colors.deepOrange,
                    child: FilterChipGroup(
                      chips: [
                        FilterChipData(
                          key: OrderSortOption.newestFirst.name,
                          label: l10n.orderFilterSortNewest,
                        ),
                        FilterChipData(
                          key: OrderSortOption.oldestFirst.name,
                          label: l10n.orderFilterSortOldest,
                        ),
                        FilterChipData(
                          key: OrderSortOption.highestAmount.name,
                          label: l10n.orderFilterSortHighestAmount,
                        ),
                        FilterChipData(
                          key: OrderSortOption.lowestAmount.name,
                          label: l10n.orderFilterSortLowestAmount,
                        ),
                      ],
                      selectedKeys: {_draft.sortBy.name},
                      onSelected:
                          (key) => setState(() {
                            _draft = _draft.copyWith(
                              sortBy: OrderSortOption.values.byName(key),
                            );
                          }),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusRound,
                    ),
                  ),
                ),
                child: Text(
                  l10n.filterApply,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
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

/// Loads store display names for the given order documents.
Future<Map<String, String>> loadStoreNamesForOrders(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  AppLocalizations l10n,
) async {
  final ids = collectStoreIds(docs);
  if (ids.isEmpty) return {};

  final snaps = await Future.wait(
    ids.map(
      (id) => FirebaseFirestore.instance.collection('stores').doc(id).get(),
    ),
  );

  final names = <String, String>{};
  for (final snap in snaps) {
    if (!snap.exists) continue;
    names[snap.id] = (snap.data()?['name'] as String?) ?? l10n.unknownStore;
  }
  return names;
}
