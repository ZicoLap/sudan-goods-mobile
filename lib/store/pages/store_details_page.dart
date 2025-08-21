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

class StoreDetailsPage extends StatelessWidget {
  final String storeId;
  const StoreDetailsPage({super.key, required this.storeId});

  @override
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
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text('Store Details', style: AppTypography.heading6),
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
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text('Store not found', style: AppTypography.heading6),
              centerTitle: true,
            ),
            body: const Center(child: Text('Store not found')),
          );
        }

        final store = Store.fromDocument(snapshot.data!);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(store.name, style: AppTypography.heading6),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
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
          bottomNavigationBar: SafeArea(
            child: FloatingCartBar(storeId: storeId),
          ),
        );
      },
    );
  }
}

class _StoreDetailsSkeleton extends StatelessWidget {
  const _StoreDetailsSkeleton();

  @override
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

class _InfoSkeleton extends StatelessWidget {
  const _InfoSkeleton();

  @override
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
