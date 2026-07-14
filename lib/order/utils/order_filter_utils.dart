import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/order/models/order_filter.dart';

bool _matchesAmount(double total, AmountRangePreset preset) {
  switch (preset) {
    case AmountRangePreset.any:
      return true;
    case AmountRangePreset.under25:
      return total < 25;
    case AmountRangePreset.from25to50:
      return total >= 25 && total <= 50;
    case AmountRangePreset.from50to100:
      return total > 50 && total <= 100;
    case AmountRangePreset.over100:
      return total > 100;
  }
}

bool _matchesDate(DateTime? createdAt, DateRangePreset preset) {
  if (preset == DateRangePreset.allTime) return true;
  if (createdAt == null) return false;

  final now = DateTime.now();
  final cutoff = switch (preset) {
    DateRangePreset.last7Days => now.subtract(const Duration(days: 7)),
    DateRangePreset.last30Days => now.subtract(const Duration(days: 30)),
    DateRangePreset.last3Months => now.subtract(const Duration(days: 90)),
    DateRangePreset.allTime => DateTime.fromMillisecondsSinceEpoch(0),
  };

  return !createdAt.isBefore(cutoff);
}

bool _matchesPayment(String? paymentStatus, String? filter) {
  if (filter == null) return true;
  final normalized = (paymentStatus ?? '').toLowerCase();
  if (filter == 'paid') return normalized == 'paid';
  if (filter == 'unpaid') {
    return normalized.isEmpty || normalized == 'unpaid' || normalized == '-';
  }
  return true;
}

bool _matchesStatus(String orderStatus, Set<String> selected) {
  if (selected.isEmpty) return true;
  return selected.contains(orderStatus.toLowerCase());
}

List<QueryDocumentSnapshot<Map<String, dynamic>>> applyOrderFilters(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  OrderFilter filter,
) {
  return docs.where((doc) {
    final data = doc.data();
    final status = (data['status'] as String?) ?? 'pending';
    final storeId = (data['storeId'] as String?) ?? '';
    final total = (data['total'] as num?)?.toDouble() ?? 0.0;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final paymentStatus = data['paymentStatus'] as String?;

    if (!_matchesStatus(status, filter.statuses)) return false;
    if (filter.storeId != null && storeId != filter.storeId) return false;
    if (!_matchesAmount(total, filter.amountPreset)) return false;
    if (!_matchesDate(createdAt, filter.datePreset)) return false;
    if (!_matchesPayment(paymentStatus, filter.paymentStatus)) return false;

    return true;
  }).toList();
}

void sortOrders(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  OrderSortOption sortBy,
) {
  int compareCreatedAt(
    QueryDocumentSnapshot<Map<String, dynamic>> a,
    QueryDocumentSnapshot<Map<String, dynamic>> b,
  ) {
    final aDate =
        (a.data()['createdAt'] as Timestamp?)?.toDate() ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final bDate =
        (b.data()['createdAt'] as Timestamp?)?.toDate() ??
        DateTime.fromMillisecondsSinceEpoch(0);
    return aDate.compareTo(bDate);
  }

  double totalOf(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      (doc.data()['total'] as num?)?.toDouble() ?? 0.0;

  switch (sortBy) {
    case OrderSortOption.newestFirst:
      docs.sort((a, b) => compareCreatedAt(b, a));
    case OrderSortOption.oldestFirst:
      docs.sort(compareCreatedAt);
    case OrderSortOption.highestAmount:
      docs.sort((a, b) => totalOf(b).compareTo(totalOf(a)));
    case OrderSortOption.lowestAmount:
      docs.sort((a, b) => totalOf(a).compareTo(totalOf(b)));
  }
}

Set<String> collectStoreIds(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
) {
  return docs
      .map((doc) => (doc.data()['storeId'] as String?) ?? '')
      .where((id) => id.isNotEmpty)
      .toSet();
}

/// Describes active filters for removable pills in the orders list header.
class ActiveOrderFilterChip {
  const ActiveOrderFilterChip({
    required this.id,
    required this.label,
    required this.onRemove,
  });

  final String id;
  final String label;
  final VoidCallback onRemove;
}

List<ActiveOrderFilterChip> buildActiveFilterChips({
  required OrderFilter filter,
  required AppLocalizations l10n,
  required Map<String, String> storeNames,
  required void Function(OrderFilter updated) onUpdate,
}) {
  final chips = <ActiveOrderFilterChip>[];

  if (filter.statuses.isNotEmpty) {
    final labels = filter.statuses.map((s) => _statusLabel(l10n, s)).join(', ');
    chips.add(
      ActiveOrderFilterChip(
        id: 'status',
        label: labels,
        onRemove: () => onUpdate(filter.copyWith(statuses: {})),
      ),
    );
  }

  if (filter.storeId != null) {
    final name = storeNames[filter.storeId!] ?? l10n.unknownStore;
    chips.add(
      ActiveOrderFilterChip(
        id: 'store',
        label: name,
        onRemove: () => onUpdate(filter.copyWith(clearStoreId: true)),
      ),
    );
  }

  if (filter.amountPreset != AmountRangePreset.any) {
    chips.add(
      ActiveOrderFilterChip(
        id: 'amount',
        label: _amountLabel(l10n, filter.amountPreset),
        onRemove:
            () => onUpdate(
              filter.copyWith(amountPreset: AmountRangePreset.any),
            ),
      ),
    );
  }

  if (filter.datePreset != DateRangePreset.allTime) {
    chips.add(
      ActiveOrderFilterChip(
        id: 'date',
        label: _dateLabel(l10n, filter.datePreset),
        onRemove:
            () => onUpdate(filter.copyWith(datePreset: DateRangePreset.allTime)),
      ),
    );
  }

  if (filter.paymentStatus != null) {
    chips.add(
      ActiveOrderFilterChip(
        id: 'payment',
        label: _paymentLabel(l10n, filter.paymentStatus!),
        onRemove: () => onUpdate(filter.copyWith(clearPaymentStatus: true)),
      ),
    );
  }

  if (filter.sortBy != OrderSortOption.newestFirst) {
    chips.add(
      ActiveOrderFilterChip(
        id: 'sort',
        label: _sortLabel(l10n, filter.sortBy),
        onRemove:
            () => onUpdate(filter.copyWith(sortBy: OrderSortOption.newestFirst)),
      ),
    );
  }

  return chips;
}

String _statusLabel(AppLocalizations l10n, String status) {
  switch (status.toLowerCase()) {
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
      return status;
  }
}

String _amountLabel(AppLocalizations l10n, AmountRangePreset preset) {
  switch (preset) {
    case AmountRangePreset.any:
      return l10n.orderFilterAmountAny;
    case AmountRangePreset.under25:
      return l10n.orderFilterAmountUnder25;
    case AmountRangePreset.from25to50:
      return l10n.orderFilterAmount25to50;
    case AmountRangePreset.from50to100:
      return l10n.orderFilterAmount50to100;
    case AmountRangePreset.over100:
      return l10n.orderFilterAmountOver100;
  }
}

String _dateLabel(AppLocalizations l10n, DateRangePreset preset) {
  switch (preset) {
    case DateRangePreset.allTime:
      return l10n.orderFilterDateAllTime;
    case DateRangePreset.last7Days:
      return l10n.orderFilterDateLast7Days;
    case DateRangePreset.last30Days:
      return l10n.orderFilterDateLast30Days;
    case DateRangePreset.last3Months:
      return l10n.orderFilterDateLast3Months;
  }
}

String _paymentLabel(AppLocalizations l10n, String paymentStatus) {
  if (paymentStatus == 'paid') return l10n.orderFilterPaymentPaid;
  return l10n.orderFilterPaymentUnpaid;
}

String _sortLabel(AppLocalizations l10n, OrderSortOption sort) {
  switch (sort) {
    case OrderSortOption.newestFirst:
      return l10n.orderFilterSortNewest;
    case OrderSortOption.oldestFirst:
      return l10n.orderFilterSortOldest;
    case OrderSortOption.highestAmount:
      return l10n.orderFilterSortHighestAmount;
    case OrderSortOption.lowestAmount:
      return l10n.orderFilterSortLowestAmount;
  }
}
