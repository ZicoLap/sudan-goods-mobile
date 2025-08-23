import 'package:flutter/foundation.dart';

class StoreFilterController extends ChangeNotifier {
  String _selectedCategoryId = 'all';

  String get selectedCategoryId => _selectedCategoryId;
  bool get isAll => _selectedCategoryId == 'all';

  void selectCategory(String id) {
    if (_selectedCategoryId == id) return;
    _selectedCategoryId = id;
    notifyListeners();
  }
}
