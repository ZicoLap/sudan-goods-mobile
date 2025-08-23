import 'package:cloud_firestore/cloud_firestore.dart';

class WantedRequest {
  final String id;
  final String? userId;
  final String productName;
  final String? notes;
  final Timestamp createdAt;

  WantedRequest({
    this.id = '',
    required this.productName,
    this.userId,
    this.notes,
    Timestamp? createdAt,
  }) : createdAt = createdAt ?? Timestamp.now();

  factory WantedRequest.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WantedRequest(
      id: doc.id,
      userId: data['userId'] as String?,
      productName: data['productName'] as String? ?? '',
      notes: data['notes'] as String?,
      createdAt: data['createdAt'] is Timestamp
          ? data['createdAt'] as Timestamp
          : Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productName': productName,
      'notes': notes,
      'createdAt': createdAt,
    };
  }
}
