import '../entities/message.dart';
import '../repositories/chat_repo.dart';

class WatchMessages {
  final ChatRepo repo;
  const WatchMessages(this.repo);

  Stream<List<Message>> call(String conversationId, {int pageSize = 50}) {
    return repo.watchMessages(conversationId, pageSize: pageSize);
  }
}
