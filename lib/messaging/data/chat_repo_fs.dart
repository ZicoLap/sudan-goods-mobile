import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudan_goods/messaging/domain/entities/conversation.dart';
import 'package:sudan_goods/messaging/domain/entities/message.dart';
import 'package:sudan_goods/messaging/domain/entities/store_summary.dart';
import 'package:sudan_goods/messaging/domain/repositories/chat_repo.dart';
import 'package:sudan_goods/messaging/data/dto/conversation_dto.dart';
import 'package:sudan_goods/messaging/data/dto/message_dto.dart';

/// Firestore-backed implementation of [ChatRepo].
///
/// Note: Methods are initially stubbed to keep compile green. We'll flesh them
/// out incrementally with batched writes, pagination cursors, and robust error
/// handling.
class FirestoreChatRepo implements ChatRepo {
  final FirebaseFirestore _db;
  FirestoreChatRepo({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Conversation>> watchInbox(String userId, {int pageSize = 20}) {
    final ref = _db.collection('users').doc(userId).collection('inbox');
    return ref
        .orderBy('lastMessageAt', descending: true)
        .limit(pageSize)
        .snapshots()
        .map((qs) => qs.docs.map((d) => ConversationDto.fromInboxDoc(d, userId: userId)).toList());
  }

  @override
  Future<List<Conversation>> fetchInboxPage(String userId, {int pageSize = 20, DateTime? startAfter}) async {
    var q = _db
        .collection('users')
        .doc(userId)
        .collection('inbox')
        .orderBy('lastMessageAt', descending: true)
        .limit(pageSize);
    if (startAfter != null) {
      q = q.startAfter([Timestamp.fromDate(startAfter)]);
    }
    final snap = await q.get();
    return snap.docs.map((d) => ConversationDto.fromInboxDoc(d, userId: userId)).toList();
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId, {int pageSize = 50}) {
    final ref = _db.collection('conversations').doc(conversationId).collection('messages');
    // Stream the latest messages in ascending order for UI display
    return ref
        .orderBy('sentAt', descending: false)
        .limitToLast(pageSize)
        .snapshots()
        .map((qs) => qs.docs.map((d) => MessageDto.fromDoc(d, conversationId: conversationId)).toList());
  }

  @override
  Future<List<Message>> fetchMessagesPage(String conversationId, {int pageSize = 50, DateTime? startAfter}) async {
    var q = _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(pageSize);
    if (startAfter != null) {
      q = q.startAfter([Timestamp.fromDate(startAfter)]);
    }
    final snap = await q.get();
    final items = snap.docs.map((d) => MessageDto.fromDoc(d, conversationId: conversationId)).toList();
    // Return in chronological order (oldest -> newest)
    return items.reversed.toList();
  }

  @override
  Future<String> startConversation(String userId, StoreSummary store) async {
    final convId = _conversationIdFor(userId, store.id);
    final convRef = _db.collection('conversations').doc(convId);
    final inboxRef = _db.collection('users').doc(userId).collection('inbox').doc(convId);

    await _db.runTransaction((trx) async {
      // All reads must happen before any writes in a transaction.
      final convSnap = await trx.get(convRef);
      final inboxSnap = await trx.get(inboxRef);

      final nowCreate = ConversationDto.createConversationData(userId: userId, store: store);

      // Write conversation doc
      if (!convSnap.exists) {
        trx.set(convRef, {
          ...nowCreate,
          'lastMessageAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        // Keep store summary fresh
        trx.set(convRef, {
          'storeId': store.id,
          'storeName': store.name,
          'storeLogoUrl': store.logoUrl,
          'storeIsActive': store.isActive,
          'storeIsApproved': store.isApproved,
          'updatedAt': FieldValue.serverTimestamp(),
          'lastMessageAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Write inbox doc
      if (!inboxSnap.exists) {
        trx.set(inboxRef, {
          // flatten store summary for quick inbox render
          'storeId': store.id,
          'storeName': store.name,
          'storeLogoUrl': store.logoUrl,
          'storeIsActive': store.isActive,
          'storeIsApproved': store.isApproved,
          'unreadCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastMessageAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        trx.set(inboxRef, {
          'storeId': store.id,
          'storeName': store.name,
          'storeLogoUrl': store.logoUrl,
          'storeIsActive': store.isActive,
          'storeIsApproved': store.isApproved,
          'updatedAt': FieldValue.serverTimestamp(),
          'lastMessageAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });

    return convId;
  }

  @override
  Future<void> sendMessage(String conversationId, Message message) async {
    final convRef = _db.collection('conversations').doc(conversationId);
    final msgsRef = convRef.collection('messages').doc();
    final inboxUserId = message.senderId; // we only manage the viewing user's inbox on client
    final inboxRef = _db.collection('users').doc(inboxUserId).collection('inbox').doc(conversationId);

    final batch = _db.batch();
    batch.set(msgsRef, MessageDto.toCreateData(message));
    batch.set(convRef, ConversationDto.lastMessageUpdateData(message: message), SetOptions(merge: true));
    batch.set(inboxRef, {
      'lastMessageText': message.text,
      'lastMessageSenderId': message.senderId,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }

  @override
  Future<void> markRead(String conversationId, String userId, {String? upToMessageId}) async {
    final inboxRef = _db.collection('users').doc(userId).collection('inbox').doc(conversationId);
    final convRef = _db.collection('conversations').doc(conversationId);
    final upToRef = upToMessageId != null ? convRef.collection('messages').doc(upToMessageId) : null;

    await _db.runTransaction((trx) async {
      trx.set(inboxRef, {
        'unreadCount': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (upToRef != null) {
        trx.set(upToRef, {
          'readBy.$userId': true,
        }, SetOptions(merge: true));
      }
    });
  }

  String _conversationIdFor(String userId, String storeId) => 'u_${userId}__s_${storeId}';
}
