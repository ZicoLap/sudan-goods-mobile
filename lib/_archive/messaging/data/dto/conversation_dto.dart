import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/store_summary.dart';
import '../../domain/entities/message.dart';
import 'store_summary_dto.dart';

/// Mapper between Firestore docs and [Conversation].
class ConversationDto {
  static Conversation fromConversationDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>? ?? <String, dynamic>{});
    final store = StoreSummary(
      id: (data['storeId'] ?? '').toString(),
      name: (data['storeName'] ?? '').toString(),
      logoUrl: data['storeLogoUrl'] as String?,
      isActive: (data['storeIsActive'] ?? true) as bool,
      isApproved: (data['storeIsApproved'] ?? false) as bool,
    );
    return Conversation(
      id: doc.id,
      userId: (data['userId'] ?? '').toString(),
      store: store,
      lastMessageText: data['lastMessageText'] as String?,
      lastMessageSenderId: data['lastMessageSenderId'] as String?,
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      unreadCount: (data['unreadCount'] is int) ? data['unreadCount'] as int : 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  static Conversation fromInboxDoc(DocumentSnapshot doc, {required String userId}) {
    final data = (doc.data() as Map<String, dynamic>? ?? <String, dynamic>{});
    final store = StoreSummaryDto.fromMap(data);
    return Conversation(
      id: doc.id,
      userId: userId,
      store: store,
      lastMessageText: data['lastMessageText'] as String?,
      lastMessageSenderId: data['lastMessageSenderId'] as String?,
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      unreadCount: (data['unreadCount'] is int) ? data['unreadCount'] as int : 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> createConversationData({
    required String userId,
    required StoreSummary store,
  }) {
    return <String, dynamic>{
      'userId': userId,
      'storeId': store.id,
      'storeName': store.name,
      'storeLogoUrl': store.logoUrl,
      'storeIsActive': store.isActive,
      'storeIsApproved': store.isApproved,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> lastMessageUpdateData({required Message message}) {
    return <String, dynamic>{
      'lastMessageText': message.text,
      'lastMessageSenderId': message.senderId,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
