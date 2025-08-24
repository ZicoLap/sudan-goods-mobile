import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudan_goods/follow/domain/entities/store_summary.dart';
import 'package:sudan_goods/follow/domain/repositories/follow_repo.dart';

class FirestoreFollowRepository implements FollowRepo {
  FirestoreFollowRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _userFollowingCol(String uid) =>
      _db.collection('users').doc(uid).collection('following');

  DocumentReference<Map<String, dynamic>> _userFollowingDoc(
          String uid, String storeId) =>
      _userFollowingCol(uid).doc(storeId);

  @override
  Future<void> follow({required String uid, required StoreSummary store}) async {
    final batch = _db.batch();

    final userDoc = _userFollowingDoc(uid, store.id);
    batch.set(userDoc, {
      ...store.toFollowingDocMap(),
      'followedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: false));

    // Mirror write for analytics/admin views (client-side for now; ensure rules allow this)
    final mirrorDoc = _db.collection('stores').doc(store.id).collection('followers').doc(uid);
    batch.set(mirrorDoc, {
      'userId': uid,
      'followedAt': FieldValue.serverTimestamp(),
    });

    // Counter increment will be handled by Cloud Functions onCreate trigger later:
    // final storeDoc = _db.collection('stores').doc(store.id);
    // batch.update(storeDoc, {
    //   'followersCount': FieldValue.increment(1),
    // });

    await batch.commit();
  }

  @override
  Future<void> unfollow({required String uid, required String storeId}) async {
    final batch = _db.batch();

    final userDoc = _userFollowingDoc(uid, storeId);
    batch.delete(userDoc);

    // Mirror delete for analytics/admin views
    final mirrorDoc = _db.collection('stores').doc(storeId).collection('followers').doc(uid);
    batch.delete(mirrorDoc);

    // Counter decrement handled by Cloud Functions onDelete trigger later:
    // final storeDoc = _db.collection('stores').doc(storeId);
    // batch.update(storeDoc, {
    //   'followersCount': FieldValue.increment(-1),
    // });

    await batch.commit();
  }

  @override
  Stream<bool> isFollowing({required String uid, required String storeId}) {
    return _userFollowingDoc(uid, storeId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  @override
  Stream<List<StoreSummary>> getFollowing({
    required String uid,
    required int limit,
    String? startAfterStoreId,
  }) {
    final controller = StreamController<List<StoreSummary>>();

    () async {
      Query<Map<String, dynamic>> query = _userFollowingCol(uid)
          .orderBy('followedAt', descending: true)
          .limit(limit);

      if (startAfterStoreId != null) {
        try {
          final cursor = await _userFollowingDoc(uid, startAfterStoreId).get();
          if (cursor.exists) {
            query = query.startAfterDocument(cursor);
          }
        } catch (_) {
          // If cursor fetch fails, fall back to first page
        }
      }

      final sub = query.snapshots().listen((snapshot) {
        final out = snapshot.docs
            .map((d) => StoreSummary.fromMap(d.id, d.data()))
            .toList();
        controller.add(out);
      }, onError: controller.addError);

      controller.onCancel = () async {
        await sub.cancel();
        await controller.close();
      };
    }();

    return controller.stream;
  }
}
