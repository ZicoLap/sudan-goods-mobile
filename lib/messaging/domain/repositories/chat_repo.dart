import '../entities/conversation.dart';
import '../entities/message.dart';
import '../entities/store_summary.dart';

/// Abstract repository for messaging use cases.
///
/// Implementations should provide Firestore-backed logic with efficient
/// pagination and streaming, but the interface remains platform-agnostic.
abstract class ChatRepo {
  /// Stream the latest page of the user's inbox (conversations).
  Stream<List<Conversation>> watchInbox(
    String userId, {
    int pageSize = 20,
  });

  /// Fetch a page of the user's inbox (for pagination).
  Future<List<Conversation>> fetchInboxPage(
    String userId, {
    int pageSize = 20,
    DateTime? startAfter, // typically lastMessageAt of the last loaded item
  });

  /// Stream the latest page of messages in a conversation.
  Stream<List<Message>> watchMessages(
    String conversationId, {
    int pageSize = 50,
  });

  /// Fetch a page of messages for pagination (older messages).
  Future<List<Message>> fetchMessagesPage(
    String conversationId, {
    int pageSize = 50,
    DateTime? startAfter, // typically sentAt of the last loaded item
  });

  /// Start or get an existing conversation id for the given user ↔ store pair.
  Future<String> startConversation(String userId, StoreSummary store);

  /// Send a message in a conversation.
  Future<void> sendMessage(String conversationId, Message message);

  /// Mark messages as read up to an optional message bound.
  Future<void> markRead(String conversationId, String userId, {String? upToMessageId});
}
