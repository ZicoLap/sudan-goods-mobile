import 'package:flutter/material.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/l10n/locale_controller.dart';
import 'package:sudan_goods/Home/pages/language_settings_page.dart';
import 'package:sudan_goods/authentication/services/account_service.dart';
import 'package:sudan_goods/authentication/views/change_email_page.dart';
import 'package:sudan_goods/authentication/auth_gate_page.dart';
import 'package:sudan_goods/user/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = true;
  bool _hasError = false;

  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _orderStatusUpdates = true;

  bool _twoFactorAuth = false;

  String _themeKey = 'system';
  String _regionCode = 'SD';
  String _currencyCode = 'SDG';
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _fetchAppVersion();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? _buildLoadingSkeleton()
              : SingleChildScrollView(
                padding: const EdgeInsets.all(DesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_hasError) _errorBanner(),
                    _sectionHeader(
                      AppLocalizations.of(context)!.sectionAccount,
                    ),
                    _card(
                      children: [
                        _navTile(
                          Icons.alternate_email,
                          AppLocalizations.of(context)!.changeEmail,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ChangeEmailPage(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _navTile(
                          Icons.lock_outline,
                          AppLocalizations.of(context)!.changePassword,
                        ),
                        const Divider(height: 1),
                        _navTile(
                          Icons.location_city_outlined,
                          AppLocalizations.of(context)!.manageAddresses,
                        ),
                      ],
                    ),

                    const SizedBox(height: DesignTokens.space16),

                    _sectionHeader(
                      AppLocalizations.of(context)!.sectionNotifications,
                    ),
                    _card(
                      children: [
                        SwitchListTile.adaptive(
                          value: _pushNotifications,
                          onChanged:
                              (v) => setState(() => _pushNotifications = v),
                          title: Text(
                            AppLocalizations.of(context)!.pushNotifications,
                            style: AppTypography.body,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(
                              context,
                            )!.pushNotificationsSubtitle,
                            style: AppTypography.small,
                          ),
                          secondary: const Icon(
                            Icons.notifications_active_outlined,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.space16,
                          ),
                        ),
                        const Divider(height: 1),
                        SwitchListTile.adaptive(
                          value: _emailNotifications,
                          onChanged:
                              (v) => setState(() => _emailNotifications = v),
                          title: Text(
                            AppLocalizations.of(context)!.emailNotifications,
                            style: AppTypography.body,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(
                              context,
                            )!.emailNotificationsSubtitle,
                            style: AppTypography.small,
                          ),
                          secondary: const Icon(
                            Icons.mark_email_unread_outlined,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.space16,
                          ),
                        ),
                        const Divider(height: 1),
                        SwitchListTile.adaptive(
                          value: _orderStatusUpdates,
                          onChanged:
                              (v) => setState(() => _orderStatusUpdates = v),
                          title: Text(
                            AppLocalizations.of(context)!.orderStatusUpdates,
                            style: AppTypography.body,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(
                              context,
                            )!.orderStatusUpdatesSubtitle,
                            style: AppTypography.small,
                          ),
                          secondary: const Icon(Icons.local_shipping_outlined),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.space16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: DesignTokens.space16),

                    _sectionHeader(
                      AppLocalizations.of(context)!.sectionPrivacySecurity,
                    ),
                    _card(
                      children: [
                        SwitchListTile.adaptive(
                          value: _twoFactorAuth,
                          onChanged: (v) => setState(() => _twoFactorAuth = v),
                          title: Text(
                            AppLocalizations.of(context)!.twoFactorAuth,
                            style: AppTypography.body,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(context)!.twoFactorAuthSubtitle,
                            style: AppTypography.small,
                          ),
                          secondary: const Icon(Icons.verified_user_outlined),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.space16,
                          ),
                        ),
                        const Divider(height: 1),
                        _navTile(
                          Icons.block_outlined,
                          AppLocalizations.of(context)!.blockedUsers,
                        ),
                        const Divider(height: 1),
                        _navTile(
                          Icons.privacy_tip_outlined,
                          AppLocalizations.of(context)!.dataAndPrivacy,
                          subtitle:
                              AppLocalizations.of(
                                context,
                              )!.dataAndPrivacySubtitle,
                        ),
                      ],
                    ),

                    const SizedBox(height: DesignTokens.space16),

                    _sectionHeader(
                      AppLocalizations.of(context)!.sectionGeneral,
                    ),
                    _card(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.language_outlined),
                          title: Text(
                            AppLocalizations.of(context)!.language,
                            style: AppTypography.body,
                          ),
                          subtitle: Text(
                            _languageLabel(AppLocalizations.of(context)!),
                            style: AppTypography.small,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LanguageSettingsPage(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.brightness_6_outlined),
                          title: Text(
                            AppLocalizations.of(context)!.theme,
                            style: AppTypography.body,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(context)!.themeSubtitle,
                            style: AppTypography.small,
                          ),
                          trailing: Text(
                            _themeLabel(AppLocalizations.of(context)!),
                            style: AppTypography.smallBold,
                          ),
                          onTap: _selectTheme,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.public_outlined),
                          title: Text(
                            AppLocalizations.of(context)!.regionAndCurrency,
                            style: AppTypography.body,
                          ),
                          subtitle: Text(
                            _regionCurrencyLabel(AppLocalizations.of(context)!),
                            style: AppTypography.small,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _selectRegionCurrency,
                        ),
                      ],
                    ),

                    const SizedBox(height: DesignTokens.space16),

                    _sectionHeader(
                      AppLocalizations.of(context)!.sectionHelpSupport,
                    ),
                    _card(
                      children: [
                        _navTile(
                          Icons.help_outline,
                          AppLocalizations.of(context)!.faqs,
                        ),
                        const Divider(height: 1),
                        _navTile(
                          Icons.support_agent_outlined,
                          AppLocalizations.of(context)!.contactSupport,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: Text(
                            AppLocalizations.of(context)!.appVersion,
                            style: AppTypography.body,
                          ),
                          trailing: Text(
                            _appVersion.isNotEmpty ? _appVersion : 'v1.0.0+1',
                            style: AppTypography.smallBold,
                          ),
                          enabled: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: DesignTokens.space24),

                    _sectionHeader(AppLocalizations.of(context)!.dangerZone),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            () => _confirmAction(
                              context,
                              AppLocalizations.of(context)!.logout,
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusLarge,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: Text(AppLocalizations.of(context)!.logout),
                      ),
                    ),

                    const SizedBox(height: DesignTokens.space8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed:
                            () => _confirmAction(
                              context,
                              AppLocalizations.of(context)!.deleteAccount,
                            ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusLarge,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.delete_forever_outlined),
                        label: Text(
                          AppLocalizations.of(context)!.deleteAccount,
                        ),
                      ),
                    ),

                    const SizedBox(height: DesignTokens.space16),
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
    );
  }

  Widget _sectionHeader(String text) => Padding(
    padding: const EdgeInsets.only(left: 4.0, bottom: DesignTokens.space8),
    child: Text(text, style: AppTypography.cardTitle),
  );

  Widget _card({required List<Widget> children}) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      boxShadow: DesignTokens.shadowSmall,
    ),
    child: Column(children: children),
  );

  Widget _navTile(
    IconData icon,
    String title, {
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) => ListTile(
    leading: Icon(icon),
    title: Text(title, style: AppTypography.body),
    subtitle:
        subtitle != null ? Text(subtitle, style: AppTypography.small) : null,
    trailing: trailing ?? const Icon(Icons.chevron_right),
    onTap: onTap ?? () => _comingSoon(title),
  );

  // Helpers to map codes to localized labels
  String _languageLabel(AppLocalizations l10n) {
    final controller = Provider.of<LocaleController>(context, listen: false);
    final code =
        controller.locale.value?.languageCode ??
        Localizations.localeOf(context).languageCode;
    return code == 'ar' ? l10n.languageArabic : l10n.languageEnglish;
  }

  String _themeLabel(AppLocalizations l10n) {
    switch (_themeKey) {
      case 'light':
        return l10n.themeLight;
      case 'dark':
        return l10n.themeDark;
      default:
        return l10n.themeSystem;
    }
  }

  String _regionLabelFromCode(String code, AppLocalizations l10n) {
    switch (code) {
      case 'AE':
        return l10n.regionUAE;
      case 'US':
        return l10n.regionUS;
      default:
        return l10n.regionSudan;
    }
  }

  String _regionLabel(AppLocalizations l10n) =>
      _regionLabelFromCode(_regionCode, l10n);

  String _regionCurrencyLabel(AppLocalizations l10n) =>
      l10n.regionCurrencyFormat(_regionLabel(l10n), _currencyCode);

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.comingSoonWithFeature(feature),
        ),
      ),
    );
  }

  void _confirmAction(BuildContext context, String action) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(l10n.confirmActionTitle(action)),
            content: Text(l10n.confirmActionMessage(action)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(action),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      if (action == l10n.logout) {
        await _doLogout();
      } else if (action == l10n.deleteAccount) {
        await _doDeleteAccount();
      }
    }
  }

  Future<void> _doLogout() async {
    final l10n = AppLocalizations.of(context)!;
    await _withProgress(() async {
      try {
        await AccountService.logout();
        if (!mounted) return;
        Provider.of<UserProvider>(context, listen: false).clear();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithMessage('Failed to log out'))),
        );
      }
    });
  }

  Future<void> _doDeleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    await _withProgress(() async {
      try {
        await AccountService.deleteAccount();
        if (!mounted) return;
        Provider.of<UserProvider>(context, listen: false).clear();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (route) => false,
        );
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        final msg =
            e.code == 'requires-recent-login'
                ? l10n.errorWithMessage('Please re-authenticate to continue')
                : l10n.errorWithMessage('Failed to delete account');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithMessage('Failed to delete account')),
          ),
        );
      }
    });
  }

  Future<void> _withProgress(Future<void> Function() task) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await task();
    } finally {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }

  /*   void _selectLanguage() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = Provider.of<LocaleController>(context, listen: false);
    final selectedCode =
        controller.locale.value?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final options = ['en', 'ar'];
    final value = await showModalBottomSheet<String>(
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
                Text(l10n.selectLanguage, style: AppTypography.cardTitle),
                const SizedBox(height: 8),
                for (final code in options)
                  ListTile(
                    title: Text(
                      code == 'ar' ? l10n.languageArabic : l10n.languageEnglish,
                    ),
                    trailing:
                        selectedCode == code
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                    onTap: () => Navigator.pop(ctx, code),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
    );
    if (value != null) {
      await controller.setLanguageCode(value);
    }
  } */

  void _selectTheme() async {
    final l10n = AppLocalizations.of(context)!;
    final options = ['system', 'light', 'dark'];
    final value = await showModalBottomSheet<String>(
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
                Text(l10n.selectTheme, style: AppTypography.cardTitle),
                const SizedBox(height: 8),
                for (final key in options)
                  ListTile(
                    title: Text(() {
                      switch (key) {
                        case 'light':
                          return l10n.themeLight;
                        case 'dark':
                          return l10n.themeDark;
                        default:
                          return l10n.themeSystem;
                      }
                    }()),
                    trailing:
                        _themeKey == key
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                    onTap: () => Navigator.pop(ctx, key),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
    );
    if (value != null) {
      setState(() => _themeKey = value);
    }
  }

  void _selectRegionCurrency() async {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      {"region": 'SD', "currency": 'SDG'},
      {"region": 'AE', "currency": 'AED'},
      {"region": 'US', "currency": 'USD'},
    ];
    final value = await showModalBottomSheet<Map<String, String>>(
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
                Text(l10n.selectRegionCurrency, style: AppTypography.cardTitle),
                const SizedBox(height: 8),
                for (final o in options)
                  ListTile(
                    title: Text(
                      l10n.regionCurrencyFormat(
                        _regionLabelFromCode(o['region']!, l10n),
                        o['currency']!,
                      ),
                    ),
                    trailing:
                        (_regionCode == o['region'] &&
                                _currencyCode == o['currency'])
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                    onTap: () => Navigator.pop(ctx, o),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
    );
    if (value != null) {
      setState(() {
        _regionCode = value['region']!;
        _currencyCode = value['currency']!;
      });
    }
  }

  Future<void> _fetchAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _appVersion = 'v${info.version}+${info.buildNumber}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _appVersion = '';
      });
    }
  }

  Widget _errorBanner() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: DesignTokens.space12),
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
            child: Text(l10n.failedToLoadSettings, style: AppTypography.body),
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
            child: Text(l10n.retry),
          ),
        ],
      ),
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
            Container(
              height: 24,
              width: double.infinity,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: DesignTokens.space12),
            Container(height: 140, decoration: _skeletonCardDecoration()),
            const SizedBox(height: DesignTokens.space16),
            Container(
              height: 24,
              width: double.infinity,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: DesignTokens.space12),
            Container(height: 160, decoration: _skeletonCardDecoration()),
            const SizedBox(height: DesignTokens.space16),
            Container(
              height: 24,
              width: double.infinity,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: DesignTokens.space12),
            Container(height: 160, decoration: _skeletonCardDecoration()),
            const SizedBox(height: DesignTokens.space16),
            Container(
              height: 24,
              width: double.infinity,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: DesignTokens.space12),
            Container(height: 160, decoration: _skeletonCardDecoration()),
          ],
        ),
      ),
    );
  }

  BoxDecoration _skeletonCardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
  );
}
