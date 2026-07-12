import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/l10n/locale_controller.dart';
import 'package:sudan_goods/Home/pages/language_settings_page.dart';
import 'package:sudan_goods/Home/pages/manage_addresses_page.dart';
import 'package:sudan_goods/authentication/services/account_service.dart';
import 'package:sudan_goods/authentication/pages/change_email_page.dart';
import 'package:sudan_goods/authentication/pages/change_password_page.dart';
import 'package:sudan_goods/authentication/pages/edit_profile_page.dart';
import 'package:sudan_goods/authentication/auth_gate_page.dart';
import 'package:sudan_goods/authentication/user/user_model.dart';
import 'package:sudan_goods/authentication/user/user_provider.dart';
import 'package:sudan_goods/follow/presentation/controllers/follow_controller.dart';
import 'package:sudan_goods/follow/domain/entities/store_summary.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _appVersion = '';

  Stream<List<StoreSummary>>? _followingStream;
  FollowController? _lastFollowCtrl;

  @override
  void initState() {
    super.initState();
    _fetchAppVersion();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final followCtrl = Provider.of<FollowController?>(context);
    if (followCtrl != null && followCtrl != _lastFollowCtrl) {
      _followingStream = followCtrl.getFollowingPage(limit: 20);
      _lastFollowCtrl = followCtrl;
    }
  }

  Future<void> _fetchAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _appVersion = 'v${info.version}');
    } catch (_) {}
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body:
          userProvider.isUserLoaded
              ? _buildBody(context, userProvider.currentUser, l10n)
              : _buildSkeleton(),
    );
  }

  Widget _buildBody(BuildContext context, AppUser user, AppLocalizations l10n) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Hero header ──────────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: _buildHeroHeader(user),
          ),
          title: Text(
            l10n.navProfile,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Followed Stores ──────────────────────────────────────────
              _sectionLabel('Followed Stores', icon: Icons.storefront_outlined),
              const SizedBox(height: 8),
              _buildFollowedStores(l10n),
              const SizedBox(height: 28),

              // ── Settings divider ─────────────────────────────────────────
              _settingsDivider(l10n),
              const SizedBox(height: 12),

              // ── General ──────────────────────────────────────────────────
              _sectionLabel(l10n.sectionGeneral, icon: Icons.tune_rounded),
              const SizedBox(height: 8),
              _card([
                _navTile(
                  icon: Icons.language_rounded,
                  title: l10n.language,
                  subtitle: _languageLabel(l10n),
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LanguageSettingsPage(),
                        ),
                      ),
                ),
              ]),
              const SizedBox(height: 16),

              // ── Account ──────────────────────────────────────────────────
              _sectionLabel(
                l10n.sectionAccount,
                icon: Icons.manage_accounts_rounded,
              ),
              const SizedBox(height: 8),
              _card([
                _navTile(
                  icon: Icons.person_outline_rounded,
                  title: l10n.name,
                  subtitle: user.fullName,
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditProfilePage(),
                        ),
                      ),
                ),
                _divider(),
                _navTile(
                  icon: Icons.location_on_rounded,
                  title: l10n.manageAddresses,
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ManageAddressesPage(),
                        ),
                      ),
                ),
                _divider(),
                _navTile(
                  icon: Icons.alternate_email_rounded,
                  title: l10n.changeEmail,
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChangeEmailPage(),
                        ),
                      ),
                ),
                _divider(),
                _navTile(
                  icon: Icons.lock_outline_rounded,
                  title: l10n.changePassword,
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordPage(),
                        ),
                      ),
                ),
              ]),
              const SizedBox(height: 16),

              // ── App ───────────────────────────────────────────────────────
              _card([
                _staticTile(
                  icon: Icons.info_outline_rounded,
                  title: l10n.appVersion,
                  value: _appVersion.isNotEmpty ? _appVersion : '—',
                ),
              ]),
              const SizedBox(height: 28),

              // ── Danger zone ───────────────────────────────────────────────
              _sectionLabel(
                l10n.dangerZone,
                icon: Icons.warning_amber_rounded,
                danger: true,
              ),
              const SizedBox(height: 8),
              _dangerButtons(l10n),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ],
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeroHeader(AppUser user) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFFD05000)],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Decorative circles ────────────────────────────────────────
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // ── Content ───────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.55),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _initials(user.fullName),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Name + email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            fontSize: 12.5,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user.phoneNumber.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_rounded,
                                size: 11,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.phoneNumber,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Followed stores ────────────────────────────────────────────────────────

  Widget _buildFollowedStores(AppLocalizations l10n) {
    final followCtrl = Provider.of<FollowController?>(context);
    if (followCtrl == null) {
      return _emptyCard(Icons.storefront_outlined, 'Sign in to follow stores.');
    }
    return Container(
      decoration: _cardDecoration(),
      child: StreamBuilder<List<StoreSummary>>(
        stream: _followingStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(minHeight: 2),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 36,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No followed stores yet',
                    style: AppTypography.small.copyWith(color: Colors.black45),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: items.length,
            separatorBuilder: (_, __) => _divider(),
            itemBuilder: (_, i) {
              final s = items[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  foregroundImage:
                      (s.logoUrl != null && s.logoUrl!.isNotEmpty)
                          ? CachedNetworkImageProvider(s.logoUrl!)
                          : null,
                  child: Text(
                    s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(s.name, style: AppTypography.bodyBold),
                subtitle:
                    s.isActive
                        ? null
                        : Text(
                          'Inactive',
                          style: AppTypography.small.copyWith(
                            color: Colors.redAccent,
                          ),
                        ),
                trailing: const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Colors.black38,
                ),
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }

  // ── Settings divider label ─────────────────────────────────────────────────

  Widget _settingsDivider(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.black.withOpacity(0.08))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            l10n.settingsTitle,
            style: AppTypography.caption.copyWith(
              color: Colors.black38,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.black.withOpacity(0.08))),
      ],
    );
  }

  // ── Danger zone buttons ────────────────────────────────────────────────────

  Widget _dangerButtons(AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _confirmAction(context, l10n.logout, l10n),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
            ),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: Text(
              l10n.logout,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmAction(context, l10n.deleteAccount, l10n),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade600,
              side: BorderSide(color: Colors.red.shade300),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
            ),
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: Text(
              l10n.deleteAccount,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // ── Skeleton ───────────────────────────────────────────────────────────────

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          Container(height: 220, color: Colors.grey.shade300),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(height: 52, decoration: _skeletonDeco()),
                const SizedBox(height: 12),
                Container(height: 100, decoration: _skeletonDeco()),
                const SizedBox(height: 12),
                Container(height: 52, decoration: _skeletonDeco()),
                const SizedBox(height: 12),
                Container(height: 100, decoration: _skeletonDeco()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _skeletonDeco() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
  );

  // ── UI helpers ─────────────────────────────────────────────────────────────

  Widget _sectionLabel(
    String text, {
    required IconData icon,
    bool danger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: danger ? Colors.red.shade400 : Colors.black45,
          ),
          const SizedBox(width: 6),
          Text(
            text.toUpperCase(),
            style: AppTypography.caption.copyWith(
              color: danger ? Colors.red.shade400 : Colors.black45,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(List<Widget> children) => Container(
    decoration: _cardDecoration(),
    child: Column(children: children),
  );

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ],
  );

  Widget _navTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    leading: _iconBubble(icon),
    title: Text(title, style: AppTypography.body),
    subtitle:
        subtitle != null
            ? Text(
              subtitle,
              style: AppTypography.small.copyWith(color: Colors.black45),
            )
            : null,
    trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
    onTap: onTap,
  );

  Widget _staticTile({
    required IconData icon,
    required String title,
    required String value,
  }) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    leading: _iconBubble(icon),
    title: Text(title, style: AppTypography.body),
    trailing: Text(
      value,
      style: AppTypography.smallBold.copyWith(color: Colors.black45),
    ),
    enabled: false,
  );

  Widget _emptyCard(IconData icon, String message) => Container(
    padding: const EdgeInsets.all(20),
    decoration: _cardDecoration(),
    child: Column(
      children: [
        Icon(icon, size: 32, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text(
          message,
          style: AppTypography.small.copyWith(color: Colors.black45),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _iconBubble(IconData icon) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.9),
          AppColors.primary.withOpacity(0.65),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Icon(icon, size: 18, color: Colors.white),
  );

  Widget _divider() =>
      Divider(height: 1, indent: 62, color: Colors.black.withOpacity(0.06));

  String _languageLabel(AppLocalizations l10n) {
    final ctrl = Provider.of<LocaleController>(context, listen: false);
    final code =
        ctrl.locale.value?.languageCode ??
        Localizations.localeOf(context).languageCode;
    return code == 'ar' ? l10n.languageArabic : l10n.languageEnglish;
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _confirmAction(
    BuildContext context,
    String action,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(l10n.confirmActionTitle(action)),
            content: Text(l10n.confirmActionMessage(action)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(action),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    if (action == l10n.logout) {
      await _doLogout(l10n);
    } else if (action == l10n.deleteAccount) {
      await _doDeleteAccount(l10n);
    }
  }

  Future<void> _doLogout(AppLocalizations l10n) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await _withProgress(() async {
      try {
        await AccountService.instance.logout();
        userProvider.clear();
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (_) => false,
        );
      } catch (_) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.errorWithMessage('Failed to log out'))),
        );
      }
    });
  }

  Future<void> _doDeleteAccount(AppLocalizations l10n) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await _withProgress(() async {
      try {
        await AccountService.instance.deleteAccount();
        userProvider.clear();
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (_) => false,
        );
      } on FirebaseAuthException catch (e) {
        final msg =
            e.code == 'requires-recent-login'
                ? l10n.errorWithMessage('Please re-authenticate first')
                : l10n.errorWithMessage('Failed to delete account');
        messenger.showSnackBar(SnackBar(content: Text(msg)));
      } catch (_) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithMessage('Failed to delete account')),
          ),
        );
      }
    });
  }

  Future<void> _withProgress(Future<void> Function() task) async {
    final dialogCtxCompleter = Completer<BuildContext>();
    unawaited(
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          if (!dialogCtxCompleter.isCompleted) dialogCtxCompleter.complete(ctx);
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
    try {
      await task();
    } finally {
      final ctx = await dialogCtxCompleter.future;
      if (ctx.mounted) Navigator.of(ctx).pop();
    }
  }
}
