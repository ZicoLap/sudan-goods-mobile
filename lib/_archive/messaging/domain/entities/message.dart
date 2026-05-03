/// Message entity representing a single chat message in a conversation.
///
/// Domain model is framework-agnostic (no Firestore types).
enum MessageKind { text, image }

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final MessageKind kind;
  final String? text; // present for text messages
  final String? imageUrl; // optional support for image messages
  final DateTime sentAt;
  final Set<String> readBy; // set of user IDs who have read this message

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.kind,
    this.text,
    this.imageUrl,
    required this.sentAt,
    this.readBy = const {},
  });

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    MessageKind? kind,
    String? text,
    String? imageUrl,
    DateTime? sentAt,
    Set<String>? readBy,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      kind: kind ?? this.kind,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      sentAt: sentAt ?? this.sentAt,
      readBy: readBy ?? this.readBy,
    );
  }

  bool get isText => kind == MessageKind.text;
  bool get isImage => kind == MessageKind.image;

  bool readByUser(String uid) => readBy.contains(uid);
}
