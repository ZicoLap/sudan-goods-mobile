import 'package:flutter/material.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/Home/pages/edit_profile_page.dart';
import 'package:sudan_goods/Home/pages/settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  bool _hasError = false;
  bool _bioExpanded = false;

  final String _displayName = 'John Doe';
  final String _handle = '@john_doe';
  final String _bio = 'Loves Sudanese spices and coffee.';

  final int _orders = 12;
  final int _favorites = 5;
  final int _reviews = 3;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.navProfile),
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
      body: SafeArea(
        child:
            _hasError
                ? _errorBanner()
                : (_isLoading
                    ? _buildLoadingSkeleton()
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(DesignTokens.space16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeaderCard(),
                          const SizedBox(height: DesignTokens.space16),
                          _buildStatsRow(),
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
                child: Text(
                  AppLocalizations.of(context)!.failedToLoadProfile,
                  style: AppTypography.body,
                ),
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
            // Header skeleton
            Container(
              padding: const EdgeInsets.all(DesignTokens.space16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
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
  );

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: DesignTokens.shadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: DesignTokens.space8),
          GestureDetector(
            onTap: _showChangePhotoSheet,
            child: Semantics(
              label: AppLocalizations.of(context)!.profilePhoto,
              child: const CircleAvatar(
                radius: 42,
                backgroundImage: AssetImage(
                  'assets/images/default_profile.jpg',
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.space12),
          Text(
            _displayName,
            style: AppTypography.heading6,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _handle,
            style: AppTypography.small.copyWith(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.space8),
          _buildBio(),
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

  Widget _buildBio() {
    if (_bio.trim().isEmpty) {
      return Text(
        AppLocalizations.of(context)!.addShortBioPrompt,
        style: AppTypography.small.copyWith(color: Colors.black54),
        textAlign: TextAlign.center,
      );
    }
    final canExpand = _bio.length > 70;
    return Column(
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            _bio,
            style: AppTypography.body,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            _bio,
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
          crossFadeState:
              _bioExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        if (canExpand)
          TextButton(
            onPressed: () => setState(() => _bioExpanded = !_bioExpanded),
            child: Text(
              _bioExpanded
                  ? AppLocalizations.of(context)!.showLess
                  : AppLocalizations.of(context)!.readMore,
            ),
          ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statChip(Icons.receipt_long_outlined, AppLocalizations.of(context)!.navOrders, _orders),
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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
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

  Widget _buildRecentActivity() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: DesignTokens.shadowSmall,
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: Text(AppLocalizations.of(context)!.recentOrder),
            subtitle: Text('#ORD-2301 • ${AppLocalizations.of(context)!.itemsCount(2)}', style: AppTypography.small),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _comingSoon(AppLocalizations.of(context)!.recentOrder),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.storefront_outlined),
            title: Text(AppLocalizations.of(context)!.viewedAStore),
            subtitle: Text('Spices of Sudan', style: AppTypography.small),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _comingSoon(AppLocalizations.of(context)!.viewedAStore),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.star_border),
            title: Text(AppLocalizations.of(context)!.leftAReview),
            subtitle: Text('Coffee beans • 4★', style: AppTypography.small),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _comingSoon(AppLocalizations.of(context)!.leftAReview),
          ),
        ],
      ),
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
                Text(AppLocalizations.of(context)!.changePhoto, style: AppTypography.cardTitle),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(AppLocalizations.of(context)!.takePhoto),
                  onTap: () => Navigator.pop(ctx),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(AppLocalizations.of(context)!.chooseFromGallery),
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
