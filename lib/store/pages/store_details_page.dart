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
      stream: FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text('Store Details', style: TextStyle(color: Colors.white)),
              centerTitle: true,
            ),
            body: const _StoreDetailsSkeleton(),
            bottomNavigationBar: SafeArea(
              child: FloatingCartBar(storeId: storeId),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text('Store not found', style: TextStyle(color: Colors.white)),
              centerTitle: true,
            ),
            body: const Center(child: Text('Store not found')),
          );
        }

        final store = Store.fromDocument(snapshot.data!);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(store.name, style: const TextStyle(color: Colors.white)),
            centerTitle: true,
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF8FBFF), Colors.white, Color(0xFFF8FBFF)],
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
                const SizedBox(height: DesignTokens.sectionSpacingMedium),
                FeaturedProductsSection(storeId: storeId),
                const SizedBox(height: DesignTokens.sectionSpacingMedium),
                CollectionsSection(storeId: storeId),
                const SizedBox(height: DesignTokens.space64),
              ],
              ),
            ),
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
            Container(height: 28, width: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
            const SizedBox(width: DesignTokens.space8),
            Container(height: 28, width: 70, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
          ],
        ),
        const SizedBox(height: DesignTokens.space12),
        Row(
          children: [
            Container(height: 16, width: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
            const SizedBox(width: DesignTokens.space8),
            Container(height: 14, width: 120, color: Colors.white),
          ],
        )
      ],
    );
  }
}
