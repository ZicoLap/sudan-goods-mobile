import 'package:sudan_goods/messaging/domain/entities/message.dart';

/// Abstract repository for support messaging use cases.
///
/// Uses a dedicated collection: `supportmessages`.
abstract class SupportRepo {
  /// Ensure or create the user's support thread and return its threadId.
  ///
  /// Convention: threadId = 'u_<userId>'. The document lives at
  /// `/supportmessages/{threadId}` and messages under `/messages` subcollection.
  Future<String> startThread(String userId);

  /// Stream the latest page of messages in the user's support thread.
  Stream<List<Message>> watchMessages(
    String threadId, {
    int pageSize = 50,
  });

  /// Fetch a page of older messages (not currently used in UI, but provided for parity).
  Future<List<Message>> fetchMessagesPage(
    String threadId, {
    int pageSize = 50,
    DateTime? startAfter,
  });

  /// Send a message in the user's support thread.
  Future<void> sendMessage(String threadId, Message message);

  /// Mark messages as read up to an optional bound.
  Future<void> markRead(String threadId, String userId, {String? upToMessageId});
}
