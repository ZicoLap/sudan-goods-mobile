import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sudan_goods/models/store/collection_model.dart';
import 'package:sudan_goods/store/pages/collection_products_page.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'collection_card.dart';
import 'shimmer_collection_card.dart';

class CollectionsSection extends StatelessWidget {
  final String storeId; // in case you want to filter by store later

  const CollectionsSection({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('collections')
          .where('storeId', isEqualTo: storeId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: DesignTokens.paddingPageHorizontal,
                child: Text(AppLocalizations.of(context)!.collectionsTitle, style: AppTypography.sectionTitle),
              ),
              const SizedBox(height: DesignTokens.space8),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space20),
                itemCount: 6,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: DesignTokens.space12,
                  mainAxisSpacing: DesignTokens.space12,
                  childAspectRatio: 3 / 4,
                ),
                itemBuilder: (_, __) => const ShimmerCollectionCard(),
              ),
            ],
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: DesignTokens.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: DesignTokens.paddingPageHorizontal,
                  child: Text(AppLocalizations.of(context)!.collectionsTitle, style: AppTypography.sectionTitle),
                ),
                const SizedBox(height: DesignTokens.space12),
                const Padding(
                  padding: DesignTokens.paddingPageHorizontal,
                  child: _EmptyCollectionsCard(),
                ),
              ],
            ),
          );
        }

        final collections = snapshot.data!.docs
            .map((doc) => Collection.fromDocument(doc))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: DesignTokens.paddingPageHorizontal,
              child: Text(AppLocalizations.of(context)!.collectionsTitle, style: AppTypography.sectionTitle),
            ),
            const SizedBox(height: DesignTokens.space8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space20),
              itemCount: collections.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: DesignTokens.space12,
                mainAxisSpacing: DesignTokens.space12,
                childAspectRatio: 3 / 4,
              ),
              itemBuilder: (context, index) {
                final collection = collections[index];

                return CollectionCard(
                  collection: collection,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => CollectionProductsPage(
                        collection: collection,
                      ),
                    ));
                    print('Tapped on ${collection.name}');
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _EmptyCollectionsCard extends StatelessWidget {
  const _EmptyCollectionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space16,
        vertical: DesignTokens.space24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: DesignTokens.shadowSmall,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gradient icon bubble centered
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.95),
                  AppColors.primary.withOpacity(0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: DesignTokens.shadowSmall,
            ),
            child: const Center(
              child: Icon(Icons.category_outlined, color: Colors.white, size: 26),
            ),
          ),
          const SizedBox(height: DesignTokens.space12),
          // Message centered under the icon
          Text(
            AppLocalizations.of(context)!.noCollectionsAvailable,
            style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
