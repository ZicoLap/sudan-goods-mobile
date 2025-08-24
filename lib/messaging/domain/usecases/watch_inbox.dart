import '../entities/conversation.dart';
import '../repositories/chat_repo.dart';

class WatchInbox {
  final ChatRepo repo;
  const WatchInbox(this.repo);

  Stream<List<Conversation>> call(String userId, {int pageSize = 20}) {
    return repo.watchInbox(userId, pageSize: pageSize);
  }
}
