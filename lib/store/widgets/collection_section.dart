import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sudan_goods/models/store/collection_model.dart';
import 'package:sudan_goods/store/pages/collection_products_page.dart';
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
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3 / 4,
            ),
            itemBuilder: (_, __) => const ShimmerCollectionCard(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('No collections available')),
          );
        }

        final collections = snapshot.data!.docs
            .map((doc) => Collection.fromDocument(doc))
            .toList();

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: collections.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3 / 4,
          ),
          itemBuilder: (context, index) {
            final collection = collections[index];

            return CollectionCard(
              collection: collection,
              onTap: () {
                // TODO: Navigate to ProductsPage for this collection
                // Navigator.push(...);
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => CollectionProductsPage(
                    collection: collection,
                  ),
                ));
                print('Tapped on ${collection.name}');
              },
            );
          },
        );
      },
    );
  }
}
