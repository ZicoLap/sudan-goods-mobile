import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sudan_goods/cart/widgets/floating_cart_bar.dart';
import 'package:sudan_goods/models/store/store_model.dart';
import 'package:sudan_goods/store/widgets/collection_section.dart';
import 'package:sudan_goods/store/widgets/featured_product_section.dart';
import 'package:sudan_goods/store/widgets/store_cover_section.dart';
import 'package:sudan_goods/store/widgets/store_info_section.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

/// Displays details for a single store, including cover, info, featured
/// products, and collections. Listens to the `stores/{storeId}` document for
/// live updates and shows skeletons while loading.
class StoreDetailsPage extends StatelessWidget {
  /// The Firestore document ID of the store to display.
  final String storeId;

  /// Creates a store details page for the provided [storeId].
  const StoreDetailsPage({super.key, required this.storeId});

  @override
  /// Builds the page and wires a [StreamBuilder] to `stores/{storeId}`, rendering
  /// loading, error/not-found, or the full store details layout.
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('stores')
              .doc(storeId)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            body: Column(
              children: [
                // Modern hero banner for loading state
                _StoreHeroBanner(
                  title:
                      AppLocalizations.of(context)?.storeDetailsTitle ??
                      'Store Details',
                  subtitle: '',
                  onBack: () => Navigator.of(context).pop(),
                ),
                Expanded(child: const _StoreDetailsSkeleton()),
              ],
            ),
            bottomNavigationBar: SafeArea(
              child: FloatingCartBar(storeId: storeId),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            body: Column(
              children: [
                _StoreHeroBanner(
                  title:
                      AppLocalizations.of(context)?.storeNotFound ??
                      'Store not found',
                  subtitle: '',
                  onBack: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade400,
                                Colors.grey.shade300,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.storefront_outlined,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.space16),
                        Text(
                          AppLocalizations.of(context)?.storeNotFound ??
                              'Store not found',
                          style: AppTypography.heading5.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.space8),
                        Text(
                          AppLocalizations.of(context)?.storeNotFoundSubtitle ??
                              'The store you\'re looking for doesn\'t exist.',
                          style: AppTypography.body.copyWith(
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final store = Store.fromDocument(snapshot.data!);
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: Column(
            children: [
              // ── Modern Hero Banner ─────────────────────────────────────────
              _StoreHeroBanner(
                title: store.name,
                subtitle:
                    store.isOpen
                        ? (l10n?.storeOpen ?? 'Open')
                        : (l10n?.storeClosed ?? 'Closed'),
                subtitleColor:
                    store.isOpen ? Colors.green.shade300 : Colors.red,
                onBack: () => Navigator.of(context).pop(),
                onShare: () {
                  // TODO: Implement share functionality
                },
              ),

              // ── Content ────────────────────────────────────────────────────
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFF8FBFF),
                        Colors.white,
                        Color(0xFFF8FBFF),
                      ],
                      stops: [0.0, 0.6, 1.0],
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StoreCoverSection(store: store),
                        StoreInfoSection(store: store),
                        const SizedBox(
                          height: DesignTokens.sectionSpacingMedium,
                        ),
                        FeaturedProductsSection(storeId: storeId),
                        const SizedBox(
                          height: DesignTokens.sectionSpacingMedium,
                        ),
                        CollectionsSection(storeId: storeId),
                        const SizedBox(height: DesignTokens.space64),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: FloatingCartBar(storeId: storeId),
          ),
        );
      },
    );
  }
}

/// Shimmer-based placeholder shown while store details are loading.
class _StoreDetailsSkeleton extends StatelessWidget {
  const _StoreDetailsSkeleton();

  @override
  /// Builds a scaffold skeleton UI for the store details using Shimmer.
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space20,
                vertical: DesignTokens.space12,
              ),
              child: Container(
                height: isTablet ? 400 : 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const Padding(
              padding: DesignTokens.paddingPageHorizontal,
              child: _InfoSkeleton(),
            ),
            const SizedBox(height: DesignTokens.space16),
          ],
        ),
      ),
    );
  }
}

/// Simple info section skeleton used inside the shimmer placeholder.
class _InfoSkeleton extends StatelessWidget {
  const _InfoSkeleton();

  @override
  /// Builds placeholder rows for the store name, tags and meta information.
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 20, width: 180, color: Colors.white),
        const SizedBox(height: DesignTokens.space8),
        Container(height: 12, width: 240, color: Colors.white),
        const SizedBox(height: DesignTokens.space12),
        Row(
          children: [
            Container(
              height: 28,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: DesignTokens.space8),
            Container(
              height: 28,
              width: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.space12),
        Row(
          children: [
            Container(
              height: 16,
              width: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: DesignTokens.space8),
            Container(height: 14, width: 120, color: Colors.white),
          ],
        ),
      ],
    );
  }
}

// ── Store Hero Banner ────────────────────────────────────────────────────────
/// Ultra-modern gradient hero banner with glassmorphism effects and animations.
class _StoreHeroBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? subtitleColor;
  final VoidCallback onBack;
  final VoidCallback? onShare;

  const _StoreHeroBanner({
    required this.title,
    required this.subtitle,
    this.subtitleColor,
    required this.onBack,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFFD05000)],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Decorative background elements
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 80,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            // Subtle grid pattern overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back button with gradient bubble
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.25),
                              Colors.white.withValues(alpha: 0.10),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Store icon with gradient ring
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.9),
                            Colors.white.withValues(alpha: 0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.95),
                              const Color(0xFFD05000).withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.store_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title and status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Status dot indicator
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        subtitleColor ??
                                        Colors.white.withValues(alpha: 0.7),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (subtitleColor ?? Colors.white)
                                            .withValues(alpha: 0.4),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Share button with gradient bubble
                    if (onShare != null)
                      GestureDetector(
                        onTap: onShare,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.25),
                                Colors.white.withValues(alpha: 0.10),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.share_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
