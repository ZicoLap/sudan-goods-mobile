import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sudan_goods/models/store/product_model.dart';
import 'package:sudan_goods/store/widgets/product_detail_bottom_sheet.dart';
import 'featured_product_card.dart';

class FeaturedProductsSection extends StatelessWidget {
  final String storeId;

  const FeaturedProductsSection({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('storeId', isEqualTo: storeId)
          .where('isFeatured', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox(); // 🔕 Don't show the section if empty
        }

        final products = snapshot.data!.docs
            .map((doc) => Product.fromDocument(doc))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Featured Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final product = products[index];

                  return InkWell(
                    onTap: () {
                      // TODO: Navigate to product detail page
                       showProductDetailsBottomSheet(context, products[index]);
                      print('Tapped on product: ${product.name}');
                    },
                    child: FeaturedProductCard(product: product),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void showProductDetailsBottomSheet(BuildContext context, Product product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => ProductDetailsBottomSheet(product: product),
  );
}

}
