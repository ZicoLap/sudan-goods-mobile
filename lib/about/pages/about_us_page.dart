import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sudan_goods/about/controllers/about_us_controller.dart';
import 'package:sudan_goods/about/models/about_us_content.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = Provider.of<AboutUsController>(context, listen: false);
      if (!ctrl.isLoaded && !ctrl.isLoading) {
        ctrl.load().then((_) {
          if (mounted) _fadeController.forward();
        });
      } else if (ctrl.isLoaded) {
        _fadeController.value = 1.0;
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          l10n.aboutUs,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Consumer<AboutUsController>(
          builder: (context, ctrl, _) {
            if (ctrl.isLoading) return _buildSkeleton();
            if (ctrl.isError) return _buildError(l10n, ctrl);
            if (ctrl.isLoaded && ctrl.content != null) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: _buildContent(ctrl.content!, l10n),
              );
            }
            return _buildEmpty(l10n);
          },
        ),
      ),
    );
  }

  Widget _buildContent(AboutUsContent content, AppLocalizations l10n) {
    final lang = Localizations.localeOf(context).languageCode;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.space20,
        DesignTokens.space24,
        DesignTokens.space20,
        DesignTokens.space40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Brand hero ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(DesignTokens.space24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, const Color(0xFFE85D00)],
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.07),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            content.localizedTitle(lang),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.aboutUs,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.space20),

          // ── Story / body text ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(DesignTokens.space20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SelectableText(
              content.localizedBody(lang),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.75,
              ),
            ),
          ),

          // ── Contact info ──────────────────────────────────────────────
          if (content.phone != null ||
              content.email != null ||
              content.website != null) ...[
            const SizedBox(height: DesignTokens.space20),
            _ContactInfoSection(content: content, l10n: l10n),
          ],

          // ── Social media ──────────────────────────────────────────────
          if (content.instagram != null ||
              content.twitter != null ||
              content.facebook != null) ...[
            const SizedBox(height: DesignTokens.space20),
            _SocialSection(content: content, l10n: l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
            ),
            const SizedBox(height: DesignTokens.space24),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
            ...List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.space8),
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusSmall,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n, AboutUsController ctrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
            Text(
              l10n.aboutUsLoadError,
              style: AppTypography.body.copyWith(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space16),
            TextButton(
              onPressed: ctrl.load,
              child: Text(
                l10n.retry,
                style: AppTypography.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.inputField,
                ],
              ),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
          Text(
            l10n.aboutUsEmpty,
            style: AppTypography.body.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// ── Shared section card ────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 17),
              ),
              const SizedBox(width: DesignTokens.space12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space16),
          child,
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 24, color: Colors.black12);
}

// ── Contact info section ───────────────────────────────────────────────────────

class _ContactInfoSection extends StatelessWidget {
  final AboutUsContent content;
  final AppLocalizations l10n;

  const _ContactInfoSection({required this.content, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final title = l10n.aboutUsPhone == 'Phone' ? 'Contact' : 'اتصل بنا';
    return _SectionCard(
      icon: Icons.contacts_outlined,
      title: title,
      child: Column(
        children: [
          if (content.phone != null)
            _InfoRow(
              icon: Icons.phone_outlined,
              label: l10n.aboutUsPhone,
              value: content.phone!,
              onTap: () => _copy(context, content.phone!),
            ),
          if (content.email != null) ...[
            if (content.phone != null) const _RowDivider(),
            _InfoRow(
              icon: Icons.email_outlined,
              label: l10n.aboutUsEmail,
              value: content.email!,
              onTap: () => _copy(context, content.email!),
            ),
          ],
          if (content.website != null) ...[
            if (content.phone != null || content.email != null)
              const _RowDivider(),
            _InfoRow(
              icon: Icons.language_outlined,
              label: l10n.aboutUsWebsite,
              value: content.website!,
              onTap: () => _copy(context, content.website!),
            ),
          ],
        ],
      ),
    );
  }

  void _copy(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $value'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.space4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: DesignTokens.space12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(color: Colors.black45),
                ),
                Text(
                  value,
                  style: AppTypography.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.copy_outlined, size: 16, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}

// ── Social media section ───────────────────────────────────────────────────────

class _SocialSection extends StatelessWidget {
  final AboutUsContent content;
  final AppLocalizations l10n;

  const _SocialSection({required this.content, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.share_outlined,
      title: l10n.aboutUsSocial,
      child: Wrap(
        spacing: DesignTokens.space12,
        runSpacing: DesignTokens.space12,
        children: [
          if (content.instagram != null)
            _SocialChip(
              label: l10n.aboutUsInstagram,
              handle: content.instagram!,
              color: const Color(0xFFE1306C),
              icon: Icons.camera_alt_outlined,
            ),
          if (content.twitter != null)
            _SocialChip(
              label: l10n.aboutUsTwitter,
              handle: content.twitter!,
              color: const Color(0xFF000000),
              icon: Icons.alternate_email_rounded,
            ),
          if (content.facebook != null)
            _SocialChip(
              label: l10n.aboutUsFacebook,
              handle: content.facebook!,
              color: const Color(0xFF1877F2),
              icon: Icons.facebook_outlined,
            ),
        ],
      ),
    );
  }
}

class _SocialChip extends StatelessWidget {
  final String label;
  final String handle;
  final Color color;
  final IconData icon;

  const _SocialChip({
    required this.label,
    required this.handle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      onTap: () {
        Clipboard.setData(ClipboardData(text: handle));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied: $handle'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space12,
          vertical: DesignTokens.space8,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  handle,
                  style: AppTypography.small.copyWith(color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
