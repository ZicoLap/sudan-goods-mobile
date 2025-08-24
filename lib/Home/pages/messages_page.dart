import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/messaging/presentation/controllers/chat_controller.dart';
import 'package:sudan_goods/messaging/data/store_repo_fs.dart';
import 'package:sudan_goods/messaging/domain/entities/store_summary.dart' as chat_store;
import 'package:sudan_goods/messaging/domain/entities/conversation.dart' as chat_domain;
import 'package:sudan_goods/messaging/presentation/pages/chat_page.dart';
import 'package:sudan_goods/messaging/presentation/controllers/support_controller.dart';
import 'package:sudan_goods/messaging/presentation/pages/support_chat_page.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  bool _isLoading = true;
  bool _hasError = false;

  final List<_Conversation> _conversations = [
    _Conversation(
      id: 'mock-1',
      title: 'Spices of Sudan',
      lastMessage: 'Your order is ready for pickup!',
      time: '10:24 AM',
      unreadCount: 2,
      avatarAsset: 'assets/images/sudanese_spices.png',
    ),
    _Conversation(
      id: 'mock-2',
      title: 'Customer Support',
      lastMessage: 'How can we assist you today?',
      time: 'Yesterday',
      unreadCount: 0,
      avatarIcon: Icons.support_agent_outlined,
    ),
    _Conversation(
      id: 'mock-3',
      title: 'Coffee House',
      lastMessage: 'Thanks for your review ☕',
      time: 'Mon',
      unreadCount: 1,
      avatarAsset: 'assets/images/default_profile.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
    });
  }

  void _showStoreSearchSheet() {
    final repo = FirestoreStoreRepo();
    final chat = Provider.of<ChatController?>(context, listen: false);
    if (chat == null) {
      _comingSoon(AppLocalizations.of(context)!.navMessages);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String query = '';
        List<chat_store.StoreSummary> results = [];
        bool loading = false;

        Future<void> doSearch(String q, void Function(void Function()) sbSetState) async {
          final trimmed = q.trim();
          if (trimmed.isEmpty) {
            sbSetState(() {
              query = q;
              results = [];
              loading = false;
            });
            return;
          }
          sbSetState(() {
            query = q;
            loading = true;
          });
          try {
            final r = await repo.searchStores(trimmed, limit: 20);
            sbSetState(() {
              results = r;
              loading = false;
            });
          } catch (e) {
            sbSetState(() {
              loading = false;
            });
          }
        }

        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, sbSetState) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.searchHint,
                                prefixIcon: const Icon(Icons.search),
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (v) => doSearch(v, sbSetState),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (loading)
                        const LinearProgressIndicator(minHeight: 2),
                      const SizedBox(height: 8),
                      Expanded(
                        child: results.isEmpty && query.isEmpty
                            ? Center(child: Text(AppLocalizations.of(context)!.startConversationPrompt))
                            : (results.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(AppLocalizations.of(context)!.searchNoResultsTitle(query)),
                                        const SizedBox(height: 6),
                                        Text(
                                          AppLocalizations.of(context)!.searchNoResultsSubtitle,
                                          textAlign: TextAlign.center,
                                          style: AppTypography.small.copyWith(color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    controller: scrollController,
                                    itemCount: results.length,
                                    separatorBuilder: (_, __) => const Divider(height: 1),
                                    itemBuilder: (_, i) {
                                      final s = results[i];
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.grey.shade200,
                                          child: s.logoUrl == null
                                              ? const Icon(Icons.storefront_outlined)
                                              : ClipOval(
                                                  child: Image.network(
                                                    s.logoUrl!,
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) => const Icon(Icons.storefront_outlined),
                                                  ),
                                                ),
                                        ),
                                        title: Text(s.name),
                                        onTap: () async {
                                          final convId = await chat.startConversationWithStore(s);
                                          if (!mounted) return;
                                          Navigator.of(context).pop();
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => ChatPage(
                                                conversationId: convId,
                                                storeName: s.name,
                                                storeLogoUrl: s.logoUrl,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  )),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.navMessages),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _hasError
            ? _errorBanner()
            : (_isLoading
                ? _buildLoadingSkeleton()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(DesignTokens.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _searchField(),
                        const SizedBox(height: DesignTokens.space16),
                        _conversationListCard(),
                        const SizedBox(height: DesignTokens.space24),
                      ],
                    ),
                  )),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _composeNewMessage,
        label: Text(AppLocalizations.of(context)!.newMessage),
        icon: const Icon(Icons.edit_outlined),
      ),
    );
  }

  Widget _searchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: DesignTokens.shadowSmall,
      ),
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space12),
      child: TextField(
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchMessagesHint,
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search),
        ),
        onChanged: (value) {
          // Placeholder: no real filtering yet
        },
      ),
    );
  }

  Widget _conversationListCard() {
    // Try to use ChatController if available; otherwise fall back to mock list.
    final chat = Provider.of<ChatController?>(context, listen: false);
    if (chat != null) {
      return StreamBuilder<List<chat_domain.Conversation>>(
        stream: chat.watchInbox(pageSize: 20),
        builder: (context, snapshot) {
          final items = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Fallback to existing mock while loading
            return _mockConversationListCard();
          }
          if (items == null || items.isEmpty) {
            return _emptyInboxCard();
          }
          final mapped = _mapDomainConversations(items);
          return _buildConversationList(mapped);
        },
      );
    }

    // No controller provided yet; show mock list
    return _mockConversationListCard();
  }

  // Build the original mock list card
  Widget _mockConversationListCard() {
    if (_conversations.isEmpty) return _emptyInboxCard();
    return _buildConversationList(_conversations);
  }

  // Shared conversation list container
  Widget _buildConversationList(List<_Conversation> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: DesignTokens.shadowSmall,
      ),
      child: Column(
        children: [
          for (int i = 0; i < data.length; i++) ...[
            _conversationTile(data[i]),
            if (i != data.length - 1) const Divider(height: 1),
          ]
        ],
      ),
    );
  }

  // Empty state card reused by both data sources
  Widget _emptyInboxCard() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: DesignTokens.shadowSmall,
      ),
      child: Column(
        children: [
          Icon(Icons.chat_bubble_outline, size: 40, color: Colors.grey.shade500),
          const SizedBox(height: DesignTokens.space8),
          Text(AppLocalizations.of(context)!.noMessagesYet, style: AppTypography.bodyBold),
          const SizedBox(height: 4),
          Text(AppLocalizations.of(context)!.startConversationPrompt, style: AppTypography.small.copyWith(color: Colors.black54), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // Map domain conversations to local view model for reuse of tile UI
  List<_Conversation> _mapDomainConversations(List<chat_domain.Conversation> items) {
    return items.map((c) {
      final title = c.store.name;
      final last = c.lastMessageText ?? '';
      final time = _formatTimestamp(c.lastMessageAt);
      final unread = c.unreadCount;
      return _Conversation(
        id: c.id,
        title: title,
        lastMessage: last,
        time: time,
        unreadCount: unread,
        avatarAsset: null,
        avatarIcon: Icons.storefront_outlined,
        storeLogoUrl: c.store.logoUrl,
      );
    }).toList(growable: false);
  }

  String _formatTimestamp(DateTime? ts) {
    if (ts == null) return '';
    final now = DateTime.now();
    final isSameDay = ts.year == now.year && ts.month == now.month && ts.day == now.day;
    if (isSameDay) {
      final t = TimeOfDay.fromDateTime(ts);
      return t.format(context);
    }
    return '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')}';
  }

  Widget _conversationTile(_Conversation c) {
    return ListTile(
      leading: _avatar(c),
      title: Text(c.title, style: AppTypography.body),
      subtitle: Text(
        c.lastMessage,
        style: AppTypography.small.copyWith(color: Colors.black54),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(c.time, style: AppTypography.small.copyWith(color: Colors.black45)),
          const SizedBox(height: 6),
          if (c.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${c.unreadCount}', style: AppTypography.caption.copyWith(color: Colors.white)),
            ),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatPage(
              conversationId: c.id,
              storeName: c.title,
              storeLogoUrl: c.storeLogoUrl,
            ),
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16, vertical: 6),
    );
  }

  Widget _avatar(_Conversation c) {
    if (c.storeLogoUrl != null) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade200,
        child: ClipOval(
          child: Image.network(
            c.storeLogoUrl!,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.storefront_outlined),
          ),
        ),
      );
    }
    if (c.avatarAsset != null) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: AssetImage(c.avatarAsset!),
        backgroundColor: Colors.grey.shade200,
      );
    }
    if (c.avatarIcon != null) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade200,
        child: Icon(c.avatarIcon, color: Colors.black54),
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.grey.shade200,
      child: Text(c.title.isNotEmpty ? c.title[0] : '?'),
    );
  }

  Widget _errorBanner() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(DesignTokens.space16),
          padding: const EdgeInsets.all(DesignTokens.space12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: DesignTokens.space12),
              Expanded(
                child: Text(AppLocalizations.of(context)!.failedToLoadMessages, style: AppTypography.body),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _isLoading = true;
                  });
                  Future.delayed(const Duration(milliseconds: 600), () {
                    if (mounted) setState(() => _isLoading = false);
                  });
                },
                child: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            // Search field skeleton
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
            // Conversations skeleton card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
              padding: const EdgeInsets.all(DesignTokens.space16),
              child: Column(
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(height: 12, width: 140, color: Colors.grey.shade300),
                              const SizedBox(height: 6),
                              Container(height: 10, width: double.infinity, color: Colors.grey.shade300),
                            ],
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space12),
                        Container(height: 10, width: 50, color: Colors.grey.shade300),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _composeNewMessage() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.startNewMessage, style: AppTypography.cardTitle),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: Text(AppLocalizations.of(context)!.messageAStore),
              onTap: () {
                Navigator.pop(ctx);
                _showStoreSearchSheet();
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent_outlined),
              title: Text(AppLocalizations.of(context)!.contactSupport),
              onTap: () {
                Navigator.pop(ctx);
                _startSupportChat();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _comingSoon(String feature) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.comingSoonWithFeature(feature))),
    );
  }

  Future<void> _startSupportChat() async {
    final support = Provider.of<SupportController?>(context, listen: false);
    if (support == null) {
      _comingSoon(AppLocalizations.of(context)!.contactSupport);
      return;
    }
    try {
      final threadId = await support.ensureThread();
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SupportChatPage(threadId: threadId),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.failedToLoadMessages)),
      );
    }
  }
}

class _Conversation {
  final String id;
  final String title;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String? avatarAsset;
  final IconData? avatarIcon;
  final String? storeLogoUrl;

  _Conversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    this.avatarAsset,
    this.avatarIcon,
    this.storeLogoUrl,
  });
}
