import 'package:sudan_goods/models/store/store_model.dart';

/// Immutable set of criteria used to filter the store list.
///
/// Each field maps to a real property on [Store] so filters are always
/// backed by existing data. Add new criteria here and update
/// [StoreFilterController] and the UI widgets to expose them.
class StoreFilter {
  final String selectedCategoryId;
  final String? selectedCountry;
  final bool openNow;
  final bool featured;
  final bool freeDelivery;
  final double? maxMinOrder;

  const StoreFilter({
    this.selectedCategoryId = 'all',
    this.selectedCountry,
    this.openNow = false,
    this.featured = false,
    this.freeDelivery = false,
    this.maxMinOrder,
  });

  /// Returns true when no filter (other than "all" categories) is active.
  bool get isEmpty =>
      selectedCategoryId == 'all' &&
      selectedCountry == null &&
      !openNow &&
      !featured &&
      !freeDelivery &&
      maxMinOrder == null;

  /// Number of active filter criteria (category excluded from this count).
  int get activeCount {
    var count = 0;
    if (selectedCountry != null) count++;
    if (openNow) count++;
    if (featured) count++;
    if (freeDelivery) count++;
    if (maxMinOrder != null) count++;
    return count;
  }

  StoreFilter copyWith({
    String? selectedCategoryId,
    String? selectedCountry,
    bool clearSelectedCountry = false,
    bool? openNow,
    bool? featured,
    bool? freeDelivery,
    double? maxMinOrder,
    bool clearMaxMinOrder = false,
  }) {
    return StoreFilter(
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedCountry:
          clearSelectedCountry
              ? null
              : (selectedCountry ?? this.selectedCountry),
      openNow: openNow ?? this.openNow,
      featured: featured ?? this.featured,
      freeDelivery: freeDelivery ?? this.freeDelivery,
      maxMinOrder: clearMaxMinOrder ? null : (maxMinOrder ?? this.maxMinOrder),
    );
  }

  /// Whether a given [store] satisfies every active criterion.
  bool matches(Store store) {
    if (selectedCategoryId != 'all' &&
        !store.categoryIds.contains(selectedCategoryId)) {
      return false;
    }
    if (selectedCountry != null &&
        _normalize(store.address.country) != _normalize(selectedCountry)) {
      return false;
    }
    if (openNow && !store.isOpen) return false;
    if (featured && !store.isFeatured) return false;
    if (freeDelivery && store.freeDeliveryOver == null) return false;
    if (maxMinOrder != null && store.minimumOrderAmount > maxMinOrder!) {
      return false;
    }
    return true;
  }

  static String _normalize(String? value) {
    return (value ?? '').trim().toLowerCase();
  }
}
