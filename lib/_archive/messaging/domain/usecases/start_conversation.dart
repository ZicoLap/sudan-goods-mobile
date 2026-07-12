import '../entities/store_summary.dart';
import '../repositories/chat_repo.dart';

class StartConversation {
  final ChatRepo repo;
  const StartConversation(this.repo);

  Future<String> call(String userId, StoreSummary store) {
    return repo.startConversation(userId, store);
  }
}
