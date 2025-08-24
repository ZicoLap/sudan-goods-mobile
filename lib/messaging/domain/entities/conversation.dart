import 'store_summary.dart';

/// Conversation between a user and a store.
class Conversation {
  final String id;
  final String userId; // consumer user id
  final StoreSummary store; // peer store summary

  // Last message metadata for list rendering
  final String? lastMessageText;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;

  // Unread count for the viewing user (client-maintained; may be eventually
  // moved to server-side aggregation).
  final int unreadCount;

  final DateTime createdAt;
  final DateTime? updatedAt;

  const Conversation({
    required this.id,
    required this.userId,
    required this.store,
    this.lastMessageText,
    this.lastMessageSenderId,
    this.lastMessageAt,
    this.unreadCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  Conversation copyWith({
    String? id,
    String? userId,
    StoreSummary? store,
    String? lastMessageText,
    String? lastMessageSenderId,
    DateTime? lastMessageAt,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      store: store ?? this.store,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasUnread => unreadCount > 0;
}
