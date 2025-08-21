import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sudan_goods/models/store/product_model.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/models/store/cart_item_model.dart';
import 'package:sudan_goods/store/widgets/product_detail_bottom_sheet.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: DesignTokens.paddingPageHorizontal,
                child: Text('Featured Products', style: AppTypography.sectionTitle),
              ),
              const SizedBox(height: DesignTokens.space8),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space20),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, __) => const _ShimmerFeaturedItem(),
                  separatorBuilder: (_, __) => const SizedBox(width: DesignTokens.space12),
                  itemCount: 3,
                ),
              ),
            ],
          );
        }

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
              padding: DesignTokens.paddingPageHorizontal,
              child: Text('Featured Products', style: AppTypography.sectionTitle),
            ),
            const SizedBox(height: DesignTokens.space8),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space20),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: DesignTokens.space12),
                itemBuilder: (context, index) {
                  final product = products[index];

                  return Selector<CartController, int>(
                    selector: (_, c) => c.getProductQuantity(product.storeId, product.id),
                    builder: (context, qty, _) {
                      return InkWell(
                        onTap: () {
                          showProductDetailsBottomSheet(context, products[index]);
                        },
                        child: FeaturedProductCard(
                          product: product,
                          cartQuantity: qty,
                          onAdd: () {
                            context.read<CartController>().addItem(
                                  CartItem(
                                    productId: product.id,
                                    storeId: product.storeId,
                                    name: product.name,
                                    price: product.discountPrice ?? product.price,
                                    weight: product.weight,
                                    imageUrl: product.images.isNotEmpty ? product.images.first : null,
                                    quantity: 1,
                                  ),
                                );
                          },
                        ),
                      );
                    },
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

class _ShimmerFeaturedItem extends StatelessWidget {
  const _ShimmerFeaturedItem();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(DesignTokens.space12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 120, color: Colors.white),
                  const SizedBox(height: DesignTokens.space8),
                  Container(height: 12, width: 160, color: Colors.white),
                  const SizedBox(height: DesignTokens.space12),
                  Container(height: 14, width: 60, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(width: DesignTokens.space12),
            Container(width: 80, height: 80, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
