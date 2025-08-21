import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

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
      title: 'Spices of Sudan',
      lastMessage: 'Your order is ready for pickup!',
      time: '10:24 AM',
      unreadCount: 2,
      avatarAsset: 'assets/images/sudanese_spices.png',
    ),
    _Conversation(
      title: 'Customer Support',
      lastMessage: 'How can we assist you today?',
      time: 'Yesterday',
      unreadCount: 0,
      avatarIcon: Icons.support_agent_outlined,
    ),
    _Conversation(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
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
        label: const Text('New message'),
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
        decoration: const InputDecoration(
          hintText: 'Search messages',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          // Placeholder: no real filtering yet
        },
      ),
    );
  }

  Widget _conversationListCard() {
    if (_conversations.isEmpty) {
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
            Text('No messages yet', style: AppTypography.bodyBold),
            const SizedBox(height: 4),
            Text('Start a conversation with a store or support', style: AppTypography.small.copyWith(color: Colors.black54), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: DesignTokens.shadowSmall,
      ),
      child: Column(
        children: [
          for (int i = 0; i < _conversations.length; i++) ...[
            _conversationTile(_conversations[i]),
            if (i != _conversations.length - 1) const Divider(height: 1),
          ]
        ],
      ),
    );
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
      onTap: () => _comingSoon('Chat with ${c.title}'),
      contentPadding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16, vertical: 6),
    );
  }

  Widget _avatar(_Conversation c) {
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
                child: Text('Failed to load messages. Please try again.', style: AppTypography.body),
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
                child: const Text('Retry'),
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
            Text('Start new message', style: AppTypography.cardTitle),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: const Text('Message a store'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.support_agent_outlined),
              title: const Text('Contact support'),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon')),
    );
  }
}

class _Conversation {
  final String title;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String? avatarAsset;
  final IconData? avatarIcon;

  _Conversation({
    required this.title,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    this.avatarAsset,
    this.avatarIcon,
  });
}
