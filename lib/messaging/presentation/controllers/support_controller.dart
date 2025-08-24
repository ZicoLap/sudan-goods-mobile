import 'package:flutter/foundation.dart';

import '../../domain/entities/message.dart';
import '../../domain/repositories/support_repo.dart';

class SupportController extends ChangeNotifier {
  final String uid;
  final SupportRepo _repo;

  SupportController({required this.uid, required SupportRepo supportRepo}) : _repo = supportRepo;

  Future<String> ensureThread() {
    return _repo.startThread(uid);
  }

  Stream<List<Message>> watchMessages(String threadId, {int pageSize = 50}) {
    return _repo.watchMessages(threadId, pageSize: pageSize);
  }

  Future<List<Message>> fetchMessagesPage(String threadId, {int pageSize = 50, DateTime? startAfter}) {
    return _repo.fetchMessagesPage(threadId, pageSize: pageSize, startAfter: startAfter);
  }

  Future<void> sendText(String threadId, String text) async {
    final msg = Message(
      id: '',
      conversationId: threadId,
      senderId: uid,
      kind: MessageKind.text,
      text: text,
      imageUrl: null,
      sentAt: DateTime.now(),
      readBy: {uid},
    );
    await _repo.sendMessage(threadId, msg);
  }

  Future<void> markRead(String threadId, {String? upToMessageId}) {
    return _repo.markRead(threadId, uid, upToMessageId: upToMessageId);
  }
}
