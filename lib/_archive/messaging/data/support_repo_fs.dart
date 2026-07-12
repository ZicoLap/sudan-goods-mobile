import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudan_goods/messaging/data/dto/message_dto.dart';
import 'package:sudan_goods/messaging/data/dto/conversation_dto.dart' as dto; // reuse lastMessage update fields
import 'package:sudan_goods/messaging/domain/entities/message.dart';
import 'package:sudan_goods/messaging/domain/repositories/support_repo.dart';

/// Firestore-backed implementation of [SupportRepo].
///
/// Data model:
/// - Thread doc: /supportmessages/{threadId}
///   Fields: userId, lastMessage*, createdAt, updatedAt, readBy.{uid}
/// - Messages: /supportmessages/{threadId}/messages/{messageId}
class FirestoreSupportRepo implements SupportRepo {
  final FirebaseFirestore _db;
  FirestoreSupportRepo({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  String _threadIdFor(String userId) => 'u_$userId';

  @override
  Future<String> startThread(String userId) async {
    final threadId = _threadIdFor(userId);
    final threadRef = _db.collection('supportmessages').doc(threadId);

    await _db.runTransaction((trx) async {
      // All reads before writes
      final snap = await trx.get(threadRef);
      if (!snap.exists) {
        trx.set(threadRef, {
          'userId': userId,
          'lastMessageText': null,
          'lastMessageSenderId': null,
          'lastMessageAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        trx.set(threadRef, {
          'userId': userId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });

    return threadId;
  }

  @override
  Stream<List<Message>> watchMessages(String threadId, {int pageSize = 50}) {
    final ref = _db.collection('supportmessages').doc(threadId).collection('messages');
    return ref
        .orderBy('sentAt', descending: false)
        .limitToLast(pageSize)
        .snapshots()
        .map((qs) => qs.docs.map((d) => MessageDto.fromDoc(d, conversationId: threadId)).toList());
  }

  @override
  Future<List<Message>> fetchMessagesPage(String threadId, {int pageSize = 50, DateTime? startAfter}) async {
    var q = _db
        .collection('supportmessages')
        .doc(threadId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(pageSize);
    if (startAfter != null) {
      q = q.startAfter([Timestamp.fromDate(startAfter)]);
    }
    final snap = await q.get();
    final items = snap.docs.map((d) => MessageDto.fromDoc(d, conversationId: threadId)).toList();
    return items.reversed.toList();
  }

  @override
  Future<void> sendMessage(String threadId, Message message) async {
    final threadRef = _db.collection('supportmessages').doc(threadId);
    final msgsRef = threadRef.collection('messages').doc();

    final batch = _db.batch();
    batch.set(msgsRef, MessageDto.toCreateData(message));
    // Reuse conversation lastMessage update fields
    batch.set(threadRef, dto.ConversationDto.lastMessageUpdateData(message: message), SetOptions(merge: true));
    await batch.commit();
  }

  @override
  Future<void> markRead(String threadId, String userId, {String? upToMessageId}) async {
    final threadRef = _db.collection('supportmessages').doc(threadId);
    final upToRef = upToMessageId != null ? threadRef.collection('messages').doc(upToMessageId) : null;

    await _db.runTransaction((trx) async {
      trx.set(threadRef, {
        'readBy.$userId': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (upToRef != null) {
        trx.set(upToRef, {
          'readBy.$userId': true,
        }, SetOptions(merge: true));
      }
    });
  }
}
