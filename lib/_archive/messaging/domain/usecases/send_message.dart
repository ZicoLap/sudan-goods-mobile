import '../entities/message.dart';
import '../repositories/chat_repo.dart';

class SendMessage {
  final ChatRepo repo;
  const SendMessage(this.repo);

  Future<void> call(String conversationId, Message message) {
    return repo.sendMessage(conversationId, message);
  }
}
