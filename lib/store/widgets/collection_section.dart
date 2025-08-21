import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sudan_goods/models/store/collection_model.dart';
import 'package:sudan_goods/store/pages/collection_products_page.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
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
              const Padding(
                padding: DesignTokens.paddingPageHorizontal,
                child: Text('Collections', style: AppTypography.sectionTitle),
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
              children: const [
                Padding(
                  padding: DesignTokens.paddingPageHorizontal,
                  child: Text('Collections', style: AppTypography.sectionTitle),
                ),
                SizedBox(height: DesignTokens.space12),
                Padding(
                  padding: DesignTokens.paddingPageHorizontal,
                  child: _EmptyCollectionsPlaceholder(),
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
            const Padding(
              padding: DesignTokens.paddingPageHorizontal,
              child: Text('Collections', style: AppTypography.sectionTitle),
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

class _EmptyCollectionsPlaceholder extends StatelessWidget {
  const _EmptyCollectionsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
          child: const Icon(Icons.category_outlined, color: Colors.grey),
        ),
        const SizedBox(width: DesignTokens.space12),
        const Expanded(
          child: Text(
            'No collections available',
            style: AppTypography.body,
          ),
        ),
      ],
    );
  }
}
