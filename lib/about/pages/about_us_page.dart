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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Brand hero ────────────────────────────────────────────────
          _HeroBanner(title: content.localizedTitle(lang), l10n: l10n),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Story / body text ───────────────────────────────────
                _BodyCard(text: content.localizedBody(lang)),

                // ── Contact info ────────────────────────────────────────
                if (content.phone != null ||
                    content.email != null ||
                    content.website != null) ...[
                  const SizedBox(height: 20),
                  _ContactInfoSection(content: content, l10n: l10n),
                ],

                // ── Social media ────────────────────────────────────────
                if (content.instagram != null ||
                    content.twitter != null ||
                    content.facebook != null) ...[
                  const SizedBox(height: 20),
                  _SocialSection(content: content, l10n: l10n),
                ],
              ],
            ),
          ),
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

// ── Hero banner ────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final String title;
  final AppLocalizations l10n;
  const _HeroBanner({required this.title, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, const Color(0xFFD05000)],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: 30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.aboutUs,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Body text card ─────────────────────────────────────────────────────────────

class _BodyCard extends StatelessWidget {
  final String text;
  const _BodyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DesignTokens.radiusLarge),
                  bottomLeft: Radius.circular(DesignTokens.radiusLarge),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SelectableText(
                  text,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: Colors.black87,
                    height: 1.8,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          ],
        ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.black.withOpacity(0.06)),
          child,
        ],
      ),
    );
  }
}

// ── Contact info section ───────────────────────────────────────────────────────

class _ContactInfoSection extends StatelessWidget {
  final AboutUsContent content;
  final AppLocalizations l10n;

  const _ContactInfoSection({required this.content, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final title = l10n.aboutUsPhone == 'Phone' ? 'Contact' : 'اتصل بنا';
    final rows = <Widget>[];
    if (content.phone != null) {
      rows.add(
        _InfoRow(
          icon: Icons.phone_rounded,
          iconColor: const Color(0xFF34A853),
          label: l10n.aboutUsPhone,
          value: content.phone!,
          onTap: () => _copy(context, content.phone!),
        ),
      );
    }
    if (content.email != null) {
      if (rows.isNotEmpty) {
        rows.add(Divider(height: 1, color: Colors.black.withOpacity(0.06)));
      }
      rows.add(
        _InfoRow(
          icon: Icons.email_rounded,
          iconColor: const Color(0xFFF36805),
          label: l10n.aboutUsEmail,
          value: content.email!,
          onTap: () => _copy(context, content.email!),
        ),
      );
    }
    if (content.website != null) {
      if (rows.isNotEmpty) {
        rows.add(Divider(height: 1, color: Colors.black.withOpacity(0.06)));
      }
      rows.add(
        _InfoRow(
          icon: Icons.language_rounded,
          iconColor: const Color(0xFF1A73E8),
          label: l10n.aboutUsWebsite,
          value: content.website!,
          onTap: () => _copy(context, content.website!),
        ),
      );
    }
    return _SectionCard(
      icon: Icons.contacts_rounded,
      title: title,
      child: Column(children: rows),
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
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.copy_rounded, size: 15, color: Colors.black26),
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
    final rows = <Widget>[];
    if (content.instagram != null) {
      rows.add(
        _SocialRow(
          label: l10n.aboutUsInstagram,
          handle: content.instagram!,
          color: const Color(0xFFE1306C),
          icon: Icons.camera_alt_rounded,
        ),
      );
    }
    if (content.twitter != null) {
      if (rows.isNotEmpty) {
        rows.add(Divider(height: 1, color: Colors.black.withOpacity(0.06)));
      }
      rows.add(
        _SocialRow(
          label: l10n.aboutUsTwitter,
          handle: content.twitter!,
          color: const Color(0xFF1DA1F2),
          icon: Icons.alternate_email_rounded,
        ),
      );
    }
    if (content.facebook != null) {
      if (rows.isNotEmpty) {
        rows.add(Divider(height: 1, color: Colors.black.withOpacity(0.06)));
      }
      rows.add(
        _SocialRow(
          label: l10n.aboutUsFacebook,
          handle: content.facebook!,
          color: const Color(0xFF1877F2),
          icon: Icons.facebook_rounded,
        ),
      );
    }
    return _SectionCard(
      icon: Icons.share_rounded,
      title: l10n.aboutUsSocial,
      child: Column(children: rows),
    );
  }
}

class _SocialRow extends StatelessWidget {
  final String label;
  final String handle;
  final Color color;
  final IconData icon;

  const _SocialRow({
    required this.label,
    required this.handle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: color.withOpacity(0.7),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    handle,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.copy_rounded, size: 15, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
