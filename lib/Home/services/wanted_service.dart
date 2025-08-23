import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WantedService {
  final _wantedRef = FirebaseFirestore.instance.collection('wanted_requests');

  /// Submits a wanted product request. User ID is attached if available.
  Future<String> submitWantedRequest({
    required String productName,
    String? notes,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final data = {
      'productName': productName,
      'notes': notes,
      'userId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final doc = await _wantedRef.add(data);
    return doc.id;
  }
}
