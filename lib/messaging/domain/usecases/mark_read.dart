import '../repositories/chat_repo.dart';

class MarkRead {
  final ChatRepo repo;
  const MarkRead(this.repo);

  Future<void> call(String conversationId, String userId, {String? upToMessageId}) {
    return repo.markRead(conversationId, userId, upToMessageId: upToMessageId);
  }
}
