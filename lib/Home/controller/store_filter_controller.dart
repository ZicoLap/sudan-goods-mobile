import 'package:flutter/foundation.dart';
import 'package:sudan_goods/Home/models/store_filter.dart';
import 'package:sudan_goods/models/store/store_model.dart';

/// Central state controller for store browsing filters.
///
/// Keeps an immutable [StoreFilter] and exposes small, focused methods
/// to mutate individual criteria. The UI layer never edits the filter
/// directly; it calls these methods, keeping business rules isolated.
class StoreFilterController extends ChangeNotifier {
  StoreFilter _filter = const StoreFilter();

  StoreFilter get filter => _filter;

  String get selectedCategoryId => _filter.selectedCategoryId;

  bool get isAll => _filter.selectedCategoryId == 'all';

  bool get hasActiveFilters => !_filter.isEmpty;

  int get activeFilterCount => _filter.activeCount;

  void selectCategory(String id) {
    if (_filter.selectedCategoryId == id) return;
    _filter = _filter.copyWith(selectedCategoryId: id);
    notifyListeners();
  }

  void selectCountry(String? country) {
    if (_filter.selectedCountry == country) return;
    if (country == null || country.isEmpty) {
      _filter = _filter.copyWith(clearSelectedCountry: true);
    } else {
      _filter = _filter.copyWith(selectedCountry: country);
    }
    notifyListeners();
  }

  void toggleOpenNow() {
    _filter = _filter.copyWith(openNow: !_filter.openNow);
    notifyListeners();
  }

  void toggleFeatured() {
    _filter = _filter.copyWith(featured: !_filter.featured);
    notifyListeners();
  }

  void toggleFreeDelivery() {
    _filter = _filter.copyWith(freeDelivery: !_filter.freeDelivery);
    notifyListeners();
  }

  void setMaxMinOrder(double? value) {
    if (_filter.maxMinOrder == value) return;
    if (value == null || value <= 0) {
      _filter = _filter.copyWith(clearMaxMinOrder: true);
    } else {
      _filter = _filter.copyWith(maxMinOrder: value);
    }
    notifyListeners();
  }

  void resetFilters() {
    _filter = StoreFilter(selectedCategoryId: _filter.selectedCategoryId);
    notifyListeners();
  }

  /// Applies the current filter to a list of stores.
  ///
  /// Callers are responsible for supplying the already category-filtered
  /// list if they wish category to be respected at the query level.
  List<Store> apply(List<Store> stores) {
    return stores.where(_filter.matches).toList();
  }
}
