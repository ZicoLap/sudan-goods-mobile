import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudan_goods/follow/domain/entities/store_summary.dart';
import 'package:sudan_goods/follow/domain/repositories/store_repo.dart';
import 'package:sudan_goods/models/store/store_model.dart';

class FirestoreStoreRepository implements StoreRepo {
  FirestoreStoreRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Future<StoreSummary?> getSummary(String storeId) async {
    final doc = await _db.collection('stores').doc(storeId).get();
    if (!doc.exists) return null;
    final store = Store.fromDocument(doc);
    return StoreSummary.fromStore(store);
  }
}
