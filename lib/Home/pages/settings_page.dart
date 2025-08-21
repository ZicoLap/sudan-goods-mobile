import 'package:flutter/material.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:shimmer/shimmer.dart';

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

  String _language = 'English';
  String _theme = 'System';
  String _region = 'Sudan';
  String _currency = 'SDG';

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
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoadingSkeleton()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(DesignTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_hasError) _errorBanner(),
            _sectionHeader('Account'),
            _card(
              children: [
                _navTile(Icons.alternate_email, 'Change Email'),
                const Divider(height: 1),
                _navTile(Icons.lock_outline, 'Change Password'),
                const Divider(height: 1),
                _navTile(Icons.location_city_outlined, 'Manage Addresses'),
              ],
            ),

            const SizedBox(height: DesignTokens.space16),

            _sectionHeader('Notifications'),
            _card(
              children: [
                SwitchListTile.adaptive(
                  value: _pushNotifications,
                  onChanged: (v) => setState(() => _pushNotifications = v),
                  title: Text('Push notifications', style: AppTypography.body),
                  subtitle: Text('Order updates and promotions', style: AppTypography.small),
                  secondary: const Icon(Icons.notifications_active_outlined),
                  contentPadding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  value: _emailNotifications,
                  onChanged: (v) => setState(() => _emailNotifications = v),
                  title: Text('Email notifications', style: AppTypography.body),
                  subtitle: Text('News and recommendations', style: AppTypography.small),
                  secondary: const Icon(Icons.mark_email_unread_outlined),
                  contentPadding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  value: _orderStatusUpdates,
                  onChanged: (v) => setState(() => _orderStatusUpdates = v),
                  title: Text('Order status updates', style: AppTypography.body),
                  subtitle: Text('Get notified about your order progress', style: AppTypography.small),
                  secondary: const Icon(Icons.local_shipping_outlined),
                  contentPadding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16),
                ),
              ],
            ),

            const SizedBox(height: DesignTokens.space16),

            _sectionHeader('Privacy & Security'),
            _card(
              children: [
                SwitchListTile.adaptive(
                  value: _twoFactorAuth,
                  onChanged: (v) => setState(() => _twoFactorAuth = v),
                  title: Text('Two-factor authentication', style: AppTypography.body),
                  subtitle: Text('Add an extra layer of security', style: AppTypography.small),
                  secondary: const Icon(Icons.verified_user_outlined),
                  contentPadding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16),
                ),
                const Divider(height: 1),
                _navTile(Icons.block_outlined, 'Blocked users'),
                const Divider(height: 1),
                _navTile(
                  Icons.privacy_tip_outlined,
                  'Data & privacy',
                  subtitle: 'How we protect your data',
                ),
              ],
            ),

            const SizedBox(height: DesignTokens.space16),

            _sectionHeader('General'),
            _card(
              children: [
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: Text('Language', style: AppTypography.body),
                  subtitle: Text(_language, style: AppTypography.small),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectLanguage,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: Text('Theme', style: AppTypography.body),
                  subtitle: const Text('Light, Dark, or System', style: AppTypography.small),
                  trailing: Text(_theme, style: AppTypography.smallBold),
                  onTap: _selectTheme,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.public_outlined),
                  title: Text('Region & currency', style: AppTypography.body),
                  subtitle: Text('$_region ($_currency)', style: AppTypography.small),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectRegionCurrency,
                ),
              ],
            ),

            const SizedBox(height: DesignTokens.space16),

            _sectionHeader('Help & Support'),
            _card(
              children: [
                _navTile(Icons.help_outline, 'FAQs'),
                const Divider(height: 1),
                _navTile(Icons.support_agent_outlined, 'Contact Support'),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text('App version', style: AppTypography.body),
                  trailing: Text('v1.0.0+1', style: AppTypography.smallBold),
                  enabled: false,
                ),
              ],
            ),

            const SizedBox(height: DesignTokens.space24),

            _sectionHeader('Danger Zone'),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _confirmAction(context, 'Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),

            const SizedBox(height: DesignTokens.space8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmAction(context, 'Delete Account'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                  ),
                ),
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Delete Account'),
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

  Widget _navTile(IconData icon, String title, {String? subtitle, VoidCallback? onTap, Widget? trailing}) => ListTile(
        leading: Icon(icon),
        title: Text(title, style: AppTypography.body),
        subtitle: subtitle != null ? Text(subtitle, style: AppTypography.small) : null,
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap ?? () => _comingSoon(title),
      );

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon')),
    );
  }

  void _confirmAction(BuildContext context, String action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$action?'),
        content: Text('Are you sure you want to proceed with $action?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(action)),
        ],
      ),
    );
    if (confirmed == true) {
      _comingSoon(action);
    }
  }

  void _selectLanguage() async {
    final options = ['English', 'Arabic'];
    final value = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text('Select language', style: AppTypography.cardTitle),
            const SizedBox(height: 8),
            for (final o in options)
              ListTile(
                title: Text(o),
                trailing: _language == o ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () => Navigator.pop(ctx, o),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (value != null) {
      setState(() => _language = value);
    }
  }

  void _selectTheme() async {
    final options = ['System', 'Light', 'Dark'];
    final value = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text('Select theme', style: AppTypography.cardTitle),
            const SizedBox(height: 8),
            for (final o in options)
              ListTile(
                title: Text(o),
                trailing: _theme == o ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () => Navigator.pop(ctx, o),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (value != null) {
      setState(() => _theme = value);
    }
  }

  void _selectRegionCurrency() async {
    final options = ['Sudan (SDG)', 'United Arab Emirates (AED)', 'United States (USD)'];
    final value = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text('Select region & currency', style: AppTypography.cardTitle),
            const SizedBox(height: 8),
            for (final o in options)
              ListTile(
                title: Text(o),
                trailing: (o.contains(_region) && o.contains(_currency)) ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () => Navigator.pop(ctx, o),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (value != null) {
      final parts = RegExp(r'^(.*)\s\((.*)\)$').firstMatch(value);
      if (parts != null) {
        setState(() {
          _region = parts.group(1)!;
          _currency = parts.group(2)!;
        });
      }
    }
  }

  Widget _errorBanner() {
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
          Expanded(child: Text('Failed to load settings. Please try again.', style: AppTypography.body)),
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
            Container(height: 24, width: double.infinity, color: Colors.grey.shade300),
            const SizedBox(height: DesignTokens.space12),
            Container(height: 140, decoration: _skeletonCardDecoration()),
            const SizedBox(height: DesignTokens.space16),
            Container(height: 24, width: double.infinity, color: Colors.grey.shade300),
            const SizedBox(height: DesignTokens.space12),
            Container(height: 160, decoration: _skeletonCardDecoration()),
            const SizedBox(height: DesignTokens.space16),
            Container(height: 24, width: double.infinity, color: Colors.grey.shade300),
            const SizedBox(height: DesignTokens.space12),
            Container(height: 160, decoration: _skeletonCardDecoration()),
            const SizedBox(height: DesignTokens.space16),
            Container(height: 24, width: double.infinity, color: Colors.grey.shade300),
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
