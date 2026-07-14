enum AmountRangePreset {
  any,
  under25,
  from25to50,
  from50to100,
  over100,
}

enum DateRangePreset {
  allTime,
  last7Days,
  last30Days,
  last3Months,
}

enum OrderSortOption {
  newestFirst,
  oldestFirst,
  highestAmount,
  lowestAmount,
}

/// Client-side filter state for the orders list.
class OrderFilter {
  const OrderFilter({
    this.statuses = const {},
    this.storeId,
    this.amountPreset = AmountRangePreset.any,
    this.datePreset = DateRangePreset.allTime,
    this.paymentStatus,
    this.sortBy = OrderSortOption.newestFirst,
  });

  final Set<String> statuses;
  final String? storeId;
  final AmountRangePreset amountPreset;
  final DateRangePreset datePreset;

  /// null = any; 'paid' | 'unpaid'
  final String? paymentStatus;
  final OrderSortOption sortBy;

  factory OrderFilter.defaults() => const OrderFilter();

  bool get isDefault =>
      statuses.isEmpty &&
      storeId == null &&
      amountPreset == AmountRangePreset.any &&
      datePreset == DateRangePreset.allTime &&
      paymentStatus == null &&
      sortBy == OrderSortOption.newestFirst;

  int get activeCount {
    var count = 0;
    if (statuses.isNotEmpty) count++;
    if (storeId != null) count++;
    if (amountPreset != AmountRangePreset.any) count++;
    if (datePreset != DateRangePreset.allTime) count++;
    if (paymentStatus != null) count++;
    if (sortBy != OrderSortOption.newestFirst) count++;
    return count;
  }

  OrderFilter copyWith({
    Set<String>? statuses,
    String? storeId,
    bool clearStoreId = false,
    AmountRangePreset? amountPreset,
    DateRangePreset? datePreset,
    String? paymentStatus,
    bool clearPaymentStatus = false,
    OrderSortOption? sortBy,
  }) {
    return OrderFilter(
      statuses: statuses ?? this.statuses,
      storeId: clearStoreId ? null : (storeId ?? this.storeId),
      amountPreset: amountPreset ?? this.amountPreset,
      datePreset: datePreset ?? this.datePreset,
      paymentStatus:
          clearPaymentStatus ? null : (paymentStatus ?? this.paymentStatus),
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
