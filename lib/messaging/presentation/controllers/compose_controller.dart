import 'package:flutter/foundation.dart';

import 'chat_controller.dart';

class ComposeController extends ChangeNotifier {
  final ChatController chat;
  String? _conversationId;

  ComposeController({required this.chat});

  void setConversation(String conversationId) {
    _conversationId = conversationId;
    notifyListeners();
  }

  Future<void> sendText(String text) async {
    final id = _conversationId;
    final trimmed = text.trim();
    if (id == null || trimmed.isEmpty) return;
    await chat.sendText(id, trimmed);
  }
}
