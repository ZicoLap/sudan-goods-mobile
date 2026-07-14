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

  bool get hasFilterCriteria =>
      statuses.isNotEmpty ||
      storeId != null ||
      amountPreset != AmountRangePreset.any ||
      paymentStatus != null;

  bool get hasDateFilter => datePreset != DateRangePreset.allTime;

  bool get hasCustomSort => sortBy != OrderSortOption.newestFirst;

  bool get isDefault =>
      !hasFilterCriteria && !hasDateFilter && !hasCustomSort;

  /// Count of filter criteria only (excludes date and sort).
  int get filterActiveCount {
    var count = 0;
    if (statuses.isNotEmpty) count++;
    if (storeId != null) count++;
    if (amountPreset != AmountRangePreset.any) count++;
    if (paymentStatus != null) count++;
    return count;
  }

  /// Alias for [filterActiveCount].
  int get activeCount => filterActiveCount;

  /// Clears filter criteria while preserving date and sort.
  OrderFilter clearFilterCriteria() {
    return copyWith(
      statuses: {},
      clearStoreId: true,
      amountPreset: AmountRangePreset.any,
      clearPaymentStatus: true,
    );
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
