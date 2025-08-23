import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudan_goods/models/store/product_model.dart';
import 'package:sudan_goods/models/store/store_model.dart';

class StoreWithProducts {
  final Store store;
  final List<Product> products;
  StoreWithProducts({required this.store, required this.products});
}

class SearchService {
  final _productsRef = FirebaseFirestore.instance.collection('products');
  final _storesRef = FirebaseFirestore.instance.collection('stores');

  /// Naive substring search over product names.
  /// Firestore cannot do case-insensitive substring queries natively, so we:
  /// - Fetch a limited set of available products
  /// - Filter client-side by `name.toLowerCase().contains(queryLower)`
  /// - Group by store and attach approved & active store models
  Future<List<StoreWithProducts>> searchProductsGroupedByStore(
    String query, {
    int productFetchLimit = 120,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    // 1) Fetch available products (limited)
    final snap = await _productsRef
        .where('isAvailable', isEqualTo: true)
        .limit(productFetchLimit)
        .get();

    final all = snap.docs.map(Product.fromDocument).toList();

    // 2) Filter by substring on the client
    final filtered = all.where((p) => p.name.toLowerCase().contains(q)).toList();

    if (filtered.isEmpty) return [];

    // 3) Group by storeId
    final Map<String, List<Product>> byStore = {};
    for (final p in filtered) {
      byStore.putIfAbsent(p.storeId, () => []).add(p);
    }

    // 4) Load store models, chunking whereIn by 10
    final storeIds = byStore.keys.toList();
    final storesMap = await _fetchStoresByIds(storeIds);

    // 5) Build results including only approved & active stores
    final results = <StoreWithProducts>[];
    for (final sid in storeIds) {
      final store = storesMap[sid];
      if (store == null) continue;
      if (!(store.isActive && store.isApproved)) continue;
      results.add(StoreWithProducts(store: store, products: byStore[sid]!));
    }

    return results;
  }

  Future<Map<String, Store>> _fetchStoresByIds(List<String> ids) async {
    final Map<String, Store> out = {};
    const int chunkSize = 10; // Firestore whereIn max

    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(i, i + chunkSize > ids.length ? ids.length : i + chunkSize);
      final snap = await _storesRef.where(FieldPath.documentId, whereIn: chunk).get();
      for (final d in snap.docs) {
        out[d.id] = Store.fromDocument(d);
      }
    }

    return out;
  }
}
