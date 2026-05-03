import 'package:sudan_goods/messaging/data/chat_repo_fs.dart';
import 'package:sudan_goods/messaging/presentation/controllers/chat_controller.dart';

ChatController makeChatControllerForUid(String uid) {
  final repo = FirestoreChatRepo();
  return ChatController(uid: uid, chatRepo: repo);
}
