import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ContactService {
  final FirebaseFirestore _db;

  ContactService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<void> submit({
    required String uid,
    required String email,
    required String subject,
    required String message,
  }) async {
    final docId = const Uuid().v4();
    await _db.collection('contact_messages').doc(docId).set({
      'uid': uid,
      'email': email,
      'subject': subject,
      'message': message,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
