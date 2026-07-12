import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/message.dart';

class MessageDto {
  static Message fromDoc(DocumentSnapshot doc, {required String conversationId}) {
    final data = (doc.data() as Map<String, dynamic>? ?? <String, dynamic>{});
    final String? imageUrl = data['imageUrl'] as String?;
    final String? text = data['text'] as String?;
    final kind = (imageUrl != null && (text == null || text.isEmpty))
        ? MessageKind.image
        : MessageKind.text;
    return Message(
      id: doc.id,
      conversationId: conversationId,
      senderId: (data['senderId'] ?? '').toString(),
      kind: kind,
      text: text,
      imageUrl: imageUrl,
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readBy: _readByToSet(data['readBy'] as Map<String, dynamic>?),
    );
  }

  static Map<String, dynamic> toCreateData(Message message) {
    return <String, dynamic>{
      'senderId': message.senderId,
      'text': message.text,
      'imageUrl': message.imageUrl,
      'sentAt': FieldValue.serverTimestamp(),
      'readBy': {
        for (final uid in message.readBy) uid: true,
      },
    };
  }

  static Set<String> _readByToSet(Map<String, dynamic>? map) {
    if (map == null) return <String>{};
    final result = <String>{};
    map.forEach((key, value) {
      if (value is bool && value) result.add(key);
    });
    return result;
  }
}
