import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sudan_goods/Home/widgets/filter_section.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/order/models/order_filter.dart';
import 'package:sudan_goods/order/utils/order_filter_utils.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

/// Bottom sheet for filtering orders (status, store, amount, payment).
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

  void _reset() => setState(() => _draft = _draft.clearFilterCriteria());

  void _apply() => Navigator.pop(context, _draft);

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.orderFilterSheetTitle,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      if (_draft.filterActiveCount > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          l10n.orderFiltersActive(_draft.filterActiveCount),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.black.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.08),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(maxHeight: 180),
                      child: ListView(
                        shrinkWrap: true,
                        children:
                            _statusKeys.map((key) {
                              return CheckboxListTile(
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                activeColor: AppColors.primary,
                                title: Text(
                                  orderStatusLabel(l10n, key),
                                  style: const TextStyle(fontSize: 13.5),
                                ),
                                value: _draft.statuses.contains(key),
                                onChanged: (checked) {
                                  setState(() {
                                    final next = Set<String>.from(
                                      _draft.statuses,
                                    );
                                    if (checked == true) {
                                      next.add(key);
                                    } else {
                                      next.remove(key);
                                    }
                                    _draft = _draft.copyWith(statuses: next);
                                  });
                                },
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilterSection(
                    icon: Icons.storefront_outlined,
                    title: l10n.orderFilterStore,
                    iconColor: Colors.blue,
                    child: DropdownButtonFormField<String>(
                      value: _draft.storeId ?? 'all',
                      isExpanded: true,
                      decoration: _fieldDecoration(),
                      items: [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text(l10n.orderFilterStoreAny),
                        ),
                        ...storeEntries.map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(
                              entry.value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (key) {
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
                    child: DropdownButtonFormField<AmountRangePreset>(
                      value: _draft.amountPreset,
                      isExpanded: true,
                      decoration: _fieldDecoration(),
                      items:
                          AmountRangePreset.values
                              .map(
                                (preset) => DropdownMenuItem(
                                  value: preset,
                                  child: Text(orderAmountLabel(l10n, preset)),
                                ),
                              )
                              .toList(),
                      onChanged: (preset) {
                        if (preset == null) return;
                        setState(() {
                          _draft = _draft.copyWith(amountPreset: preset);
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilterSection(
                    icon: Icons.payments_outlined,
                    title: l10n.orderFilterPayment,
                    iconColor: Colors.indigo,
                    child: SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'any',
                          label: Text(l10n.orderFilterPaymentAny),
                        ),
                        ButtonSegment(
                          value: 'paid',
                          label: Text(l10n.orderFilterPaymentPaid),
                        ),
                        ButtonSegment(
                          value: 'unpaid',
                          label: Text(l10n.orderFilterPaymentUnpaid),
                        ),
                      ],
                      selected: {_draft.paymentStatus ?? 'any'},
                      onSelectionChanged: (selection) {
                        final key = selection.first;
                        setState(() {
                          _draft = _draft.copyWith(
                            paymentStatus: key == 'any' ? null : key,
                            clearPaymentStatus: key == 'any',
                          );
                        });
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        textStyle: WidgetStatePropertyAll(
                          TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
