import 'package:flutter/material.dart';
import 'package:sudan_goods/contact/pages/contact_us_page.dart';
import 'package:sudan_goods/about/pages/about_us_page.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

class InfoTabPage extends StatelessWidget {
  const InfoTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Pinned hero app bar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: size.height * 0.28,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            centerTitle: true,
            title: Text(
              l10n.infoTabTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _HeroBanner(l10n: l10n),
            ),
          ),

          // ── Cards ────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.space20,
              DesignTokens.space24,
              DesignTokens.space20,
              DesignTokens.space40,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _InfoActionCard(
                  icon: Icons.mail_outline_rounded,
                  accentColor: AppColors.primary,
                  title: l10n.contactUs,
                  subtitle: l10n.contactUsSubtitle,
                  tag: l10n.contactUsTag,
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ContactUsPage(),
                        ),
                      ),
                ),
                const SizedBox(height: DesignTokens.space16),
                _InfoActionCard(
                  icon: Icons.storefront_rounded,
                  accentColor: const Color(0xFF2C7EF8),
                  title: l10n.aboutUs,
                  subtitle: l10n.aboutUsSubtitle,
                  tag: l10n.aboutUsTag,
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutUsPage()),
                      ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero banner ────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final AppLocalizations l10n;
  const _HeroBanner({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
            const Color(0xFFE85D00),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern circles
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
            bottom: 20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.infoTabTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.infoTabSubtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                      height: 1.4,
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
}

// ── Action card ────────────────────────────────────────────────────────────────

class _InfoActionCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final String tag;
  final VoidCallback onTap;

  const _InfoActionCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      child: InkWell(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        onTap: onTap,
        splashColor: accentColor.withOpacity(0.06),
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.space20),
          decoration: BoxDecoration(
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
          child: Row(
            children: [
              // Icon bubble
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: DesignTokens.space16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
