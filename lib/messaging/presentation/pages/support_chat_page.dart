import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/messaging/presentation/controllers/support_controller.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/messaging/domain/entities/message.dart' as chat_domain;

class SupportChatPage extends StatefulWidget {
  final String threadId;

  const SupportChatPage({super.key, required this.threadId});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _sending = false;
  bool _markedRead = false;
  int _lastMsgCount = 0;

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage(SupportController support) async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await support.sendText(widget.threadId, text);
      _textCtrl.clear();
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final support = Provider.of<SupportController?>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    if (support == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.contactSupport)),
        body: Center(child: Text(l10n.failedToLoadMessages)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.support_agent_outlined),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.contactSupport,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<chat_domain.Message>>(
                stream: support.watchMessages(widget.threadId, pageSize: 50),
                builder: (context, snapshot) {
                  final items = snapshot.data ?? const <chat_domain.Message>[];

                  // Mark read once when messages arrive
                  if (!_markedRead && items.isNotEmpty) {
                    _markedRead = true;
                    support.markRead(widget.threadId);
                  }

                  // Auto-scroll when new messages added
                  if (items.length != _lastMsgCount) {
                    _lastMsgCount = items.length;
                    _scrollToBottom();
                  }

                  if (snapshot.connectionState == ConnectionState.waiting && items.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          l10n.startConversationPrompt,
                          style: AppTypography.body,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final m = items[index];
                      final isMe = m.senderId == support.uid;
                      return _MessageBubble(message: m, isMe: isMe);
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            _composer(support, l10n),
          ],
        ),
      ),
    );
  }

  Widget _composer(SupportController support, AppLocalizations l10n) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textCtrl,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(support),
                decoration: InputDecoration(
                  hintText: l10n.searchMessagesHint,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: _sending
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send),
              onPressed: _sending ? null : () => _sendMessage(support),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final chat_domain.Message message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? Colors.blueAccent : Colors.grey.shade200;
    final fg = isMe ? Colors.white : Colors.black87;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(14),
      topRight: const Radius.circular(14),
      bottomLeft: isMe ? const Radius.circular(14) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(14),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: bg, borderRadius: radius),
            child: Text(
              message.text ?? '',
              style: AppTypography.body.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}
