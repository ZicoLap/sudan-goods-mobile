import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudan_goods/models/store/store_model.dart';

class StoreServices {
  final _storeRef = FirebaseFirestore.instance.collection('stores');

  Future<List<Store>> fetchFeaturedStores() async {
    try {
      final querySnapshot =
          await _storeRef
              .where('isFeatured', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .limit(10)
              .get();

      
      return querySnapshot.docs.map((doc) => Store.fromDocument(doc)).toList();
    } catch (e) {

      print('Error fetching featured stores: ${e.toString()}');
      throw Exception('Failed to fetch featured stores');
    }
  }

  Future<List<Store>> fetchAllApprovedStores() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('stores')
              .where('isActive', isEqualTo: true)
              .where('isApproved', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) => Store.fromDocument(doc)).toList();
    } catch (e) {
      print('Error fetching all stores: $e');
      throw Exception('Failed to fetch all stores');
    }
  }

  Stream<List<Store>> streamAllApprovedStores() {
    try {
      return FirebaseFirestore.instance
          .collection('stores')
          .where('isActive', isEqualTo: true)
          .where('isApproved', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) => Store.fromDocument(doc)).toList(),
          );
    } catch (e) {
      print('Stream error: $e');
      rethrow;
    }
  }

  /// Streams approved and active stores filtered by a specific [categoryId].
  ///
  /// Uses an `arrayContains` filter on the `categoryIds` field in Firestore.
  Stream<List<Store>> streamApprovedStoresByCategory(String categoryId) {
    try {
      return _storeRef
          .where('isActive', isEqualTo: true)
          .where('isApproved', isEqualTo: true)
          .where('categoryIds', arrayContains: categoryId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) => Store.fromDocument(doc)).toList(),
          );
    } catch (e) {
      print('Stream by category error: $e');
      rethrow;
    }
  }
}
