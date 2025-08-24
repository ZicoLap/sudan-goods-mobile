import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/Home/pages/edit_profile_page.dart';
import 'package:sudan_goods/Home/pages/settings_page.dart';
import 'package:sudan_goods/models/user/user_model.dart';
import 'package:sudan_goods/user/user_provider.dart';
import 'package:sudan_goods/follow/presentation/controllers/follow_controller.dart';
import 'package:sudan_goods/follow/domain/entities/store_summary.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _hasError = false;

  int _ordersCount = 0;
  final int _favorites = 0;
  final int _reviews = 0;

  // Hoisted once-per-lifecycle stream to prevent StreamBuilder churn
  Stream<List<StoreSummary>>? _followingStream;
  FollowController? _lastFollowCtrl;

  @override
  void initState() {
    super.initState();
    // Defer until after first build so Provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        if (userProvider.isUserLoaded) {
          await _fetchOrdersCount(userProvider.currentUser.uid);
        }
      } catch (_) {
        // Ignore if provider not ready yet
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize or update the followed stores stream when controller changes
    final followCtrl = Provider.of<FollowController?>(context);
    if (followCtrl != null && followCtrl != _lastFollowCtrl) {
      _followingStream = followCtrl.getFollowingPage(limit: 20);
      _lastFollowCtrl = followCtrl;
    }
  }

  Future<void> _fetchOrdersCount(String uid) async {
    try {
      final agg = FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .count();
      final snapshot = await agg.get();
      if (!mounted) return;
      setState(() {
        _ordersCount = snapshot.count ?? 0;
      });
    } catch (e) {
      // Silently ignore count errors; page still renders without stats
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isLoaded = userProvider.isUserLoaded;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(AppLocalizations.of(context)!.navProfile, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F9FC), Colors.white, Color(0xFFF7F9FC)],
          ),
        ),
        child: SafeArea(
          child: _hasError
              ? _errorBanner()
              : (!isLoaded
                  ? _buildLoadingSkeleton()
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(DesignTokens.space16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeaderCard(userProvider.currentUser),
                          const SizedBox(height: DesignTokens.space16),
                          _buildStatsRow(),
                          const SizedBox(height: DesignTokens.space16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              // No l10n key available yet
                              'Followed Stores',
                              style: AppTypography.cardTitle,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.space8),
                          _buildFollowedStores(),
                          const SizedBox(height: DesignTokens.space16),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.recentActivity,
                              style: AppTypography.cardTitle,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.space8),
                          _buildRecentActivity(),
                          const SizedBox(height: DesignTokens.space24),
                        ],
                      ),
                    )),
        ),
      ),
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
            border: Border.all(color: Colors.red.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: DesignTokens.space12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.failedToLoadProfile,
                  style: AppTypography.body,
                ),
              ),
              TextButton(
                onPressed: () async {
                  setState(() {
                    _hasError = false;
                  });
                  try {
                    await Provider.of<UserProvider>(context, listen: false).refreshUser();
                  } catch (_) {
                    if (mounted) {
                      setState(() {
                        _hasError = true;
                      });
                    }
                  }
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
            // Header skeleton
            Container(
              padding: const EdgeInsets.all(DesignTokens.space16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                boxShadow: DesignTokens.shadowSmall,
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space12),
                  Container(
                    height: 16,
                    width: 140,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 200,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 36,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
            // Card skeletons
            Container(height: 90, decoration: _skeletonCardDecoration()),
            const SizedBox(height: DesignTokens.space12),
            Container(height: 160, decoration: _skeletonCardDecoration()),
            const SizedBox(height: DesignTokens.space12),
            Container(height: 140, decoration: _skeletonCardDecoration()),
          ],
        ),
      ),
    );
  }

  BoxDecoration _skeletonCardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
    boxShadow: DesignTokens.shadowSmall,
    border: Border.all(color: Colors.black.withOpacity(0.05)),
  );

  Widget _buildHeaderCard(AppUser user) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: DesignTokens.shadowSmall,
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: DesignTokens.space8),
          GestureDetector(
            onTap: _showChangePhotoSheet,
            child: Semantics(
              label: AppLocalizations.of(context)!.profilePhoto,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.18),
                      AppColors.primary.withOpacity(0.06),
                    ],
                  ),
                  boxShadow: DesignTokens.shadowSmall,
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                    child: Text(
                      _initialsFromName(user.fullName),
                      style: AppTypography.heading6.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.space12),
          Text(
            user.fullName,
            style: AppTypography.heading6,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.space4),
          Text(
            user.email,
            style: AppTypography.small.copyWith(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.space12),
          Semantics(
            button: true,
            label: AppLocalizations.of(context)!.editProfile,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: Text(AppLocalizations.of(context)!.editProfile),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusLarge,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initialsFromName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();
    String firstLetter(String s) => s.trim().isEmpty ? '' : s.trim().substring(0, 1).toUpperCase();
    if (parts.length == 1) return firstLetter(parts.first);
    final first = firstLetter(parts.first);
    final last = firstLetter(parts.last);
    final combined = '$first$last';
    return combined.isEmpty ? '?' : combined;
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statChip(Icons.receipt_long_outlined, AppLocalizations.of(context)!.navOrders, _ordersCount),
        const SizedBox(width: DesignTokens.space12),
        _statChip(Icons.favorite_border, AppLocalizations.of(context)!.favorites, _favorites),
        const SizedBox(width: DesignTokens.space12),
        _statChip(Icons.reviews_outlined, AppLocalizations.of(context)!.reviews, _reviews),
      ],
    );
  }

  Widget _statChip(IconData icon, String label, int value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.space12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          boxShadow: DesignTokens.shadowSmall,
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Theme.of(context).primaryColor.withOpacity(0.15), Theme.of(context).primaryColor.withOpacity(0.06)],
                ),
                boxShadow: DesignTokens.shadowSmall,
              ),
              child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 6),
            Text('$value', style: AppTypography.bodyBold),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.small.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowedStores() {
    final followCtrl = Provider.of<FollowController?>(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: DesignTokens.shadowSmall,
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.space8),
        child: followCtrl == null
            ? Padding(
                padding: const EdgeInsets.all(DesignTokens.space12),
                child: Text(
                  'Please sign in to follow stores',
                  style: AppTypography.body,
                ),
              )
            : StreamBuilder<List<StoreSummary>>(
                stream: _followingStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(DesignTokens.space12),
                      child: LinearProgressIndicator(minHeight: 2),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(DesignTokens.space12),
                      child: Text(
                        AppLocalizations.of(context)!.failedToLoadProfile,
                        style: AppTypography.body,
                      ),
                    );
                  }
                  final items = snapshot.data ?? const <StoreSummary>[];
                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(DesignTokens.space12),
                      child: Text(
                        'No followed stores yet',
                        style: AppTypography.body,
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final s = items[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.12),
                          child: Text(
                            s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          foregroundImage: s.logoUrl != null && s.logoUrl!.isNotEmpty
                              ? CachedNetworkImageProvider(s.logoUrl!)
                              : null,
                        ),
                        title: Text(s.name, style: AppTypography.bodyBold),
                        subtitle: s.isActive
                            ? null
                            : Text('Inactive', style: AppTypography.small.copyWith(color: Colors.redAccent)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to store details if route is available
                        },
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: DesignTokens.shadowSmall,
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: _iconBubble(Icons.receipt_long_outlined, Colors.blueGrey),
            title: Text(AppLocalizations.of(context)!.recentOrder),
            subtitle: Text('#ORD-2301 • ${AppLocalizations.of(context)!.itemsCount(2)}', style: AppTypography.small),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _comingSoon(AppLocalizations.of(context)!.recentOrder),
          ),
          const Divider(height: 1),
          ListTile(
            leading: _iconBubble(Icons.storefront_outlined, Colors.blue),
            title: Text(AppLocalizations.of(context)!.viewedAStore),
            subtitle: Text('Spices of Sudan', style: AppTypography.small),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _comingSoon(AppLocalizations.of(context)!.viewedAStore),
          ),
          const Divider(height: 1),
          ListTile(
            leading: _iconBubble(Icons.star_border, Colors.amber),
            title: Text(AppLocalizations.of(context)!.leftAReview),
            subtitle: Text('Coffee beans • 4★', style: AppTypography.small),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _comingSoon(AppLocalizations.of(context)!.leftAReview),
          ),
        ],
      ),
    );
  }

  Widget _iconBubble(IconData icon, Color color) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.18), color.withOpacity(0.06)],
        ),
        boxShadow: DesignTokens.shadowSmall,
      ),
      child: Icon(icon, color: color),
    );
  }

  void _showChangePhotoSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Text(AppLocalizations.of(ctx)!.changePhoto, style: AppTypography.cardTitle),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(AppLocalizations.of(ctx)!.takePhoto),
                  onTap: () => Navigator.pop(ctx),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(AppLocalizations.of(ctx)!.chooseFromGallery),
                  onTap: () => Navigator.pop(ctx),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
    );
  }

  void _comingSoon(String feature) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.comingSoonWithFeature(feature))));
  }
}
