import 'package:flutter/foundation.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/store_summary.dart';
import '../../domain/repositories/chat_repo.dart';

class ChatController extends ChangeNotifier {
  final String uid;
  final ChatRepo _repo;

  ChatController({required this.uid, required ChatRepo chatRepo}) : _repo = chatRepo;

  // Inbox
  Stream<List<Conversation>> watchInbox({int pageSize = 20}) {
    return _repo.watchInbox(uid, pageSize: pageSize);
  }

  Future<List<Conversation>> fetchInboxPage({int pageSize = 20, DateTime? startAfter}) {
    return _repo.fetchInboxPage(uid, pageSize: pageSize, startAfter: startAfter);
  }

  // Conversation
  Future<String> startConversationWithStore(StoreSummary store) {
    return _repo.startConversation(uid, store);
  }

  Stream<List<Message>> watchMessages(String conversationId, {int pageSize = 50}) {
    return _repo.watchMessages(conversationId, pageSize: pageSize);
  }

  Future<List<Message>> fetchMessagesPage(String conversationId, {int pageSize = 50, DateTime? startAfter}) {
    return _repo.fetchMessagesPage(conversationId, pageSize: pageSize, startAfter: startAfter);
  }

  Future<void> sendText(String conversationId, String text) async {
    final msg = Message(
      id: '', // Firestore will assign an ID
      conversationId: conversationId,
      senderId: uid,
      kind: MessageKind.text,
      text: text,
      imageUrl: null,
      sentAt: DateTime.now(),
      readBy: {uid},
    );
    await _repo.sendMessage(conversationId, msg);
  }

  Future<void> markRead(String conversationId, {String? upToMessageId}) {
    return _repo.markRead(conversationId, uid, upToMessageId: upToMessageId);
  }
}
