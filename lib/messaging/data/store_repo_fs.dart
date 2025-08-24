import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudan_goods/messaging/domain/entities/store_summary.dart';
import 'package:sudan_goods/messaging/domain/repositories/store_repo.dart';
import 'package:sudan_goods/messaging/data/dto/store_summary_dto.dart';

/// Firestore-backed implementation of [StoreRepo].
///
/// Initially returns empty results to keep compile green; will be implemented
/// with debounced queries and indexes.
class FirestoreStoreRepo implements StoreRepo {
  final FirebaseFirestore _db;
  FirestoreStoreRepo({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  @override
  Future<StoreSummary?> getStoreSummary(String storeId) async {
    final doc = await _db.collection('stores').doc(storeId).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    final map = <String, dynamic>{...data, 'id': doc.id};
    return StoreSummaryDto.fromMap(map);
  }

  @override
  Future<List<StoreSummary>> searchStores(String query, {int limit = 20}) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return <StoreSummary>[];

    // Firestore cannot do case-insensitive substring search; fetch a limited
    // set of approved/active stores and filter client-side by name.
    final fetchLimit = ((limit * 5).clamp(20, 200)).toInt();
    final snap = await _db
        .collection('stores')
        .where('isActive', isEqualTo: true)
        .where('isApproved', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(fetchLimit)
        .get();

    final results = <StoreSummary>[];
    for (final d in snap.docs) {
      final data = d.data();
      final name = (data['name'] ?? '').toString();
      if (name.toLowerCase().contains(q)) {
        results.add(StoreSummaryDto.fromMap({...data, 'id': d.id}));
      }
      if (results.length >= limit) break;
    }
    return results;
  }
}
