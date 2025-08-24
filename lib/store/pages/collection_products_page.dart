import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/cart/widgets/floating_cart_bar.dart';
import 'package:sudan_goods/models/store/cart_item_model.dart';
import 'package:sudan_goods/models/store/collection_model.dart';
import 'package:sudan_goods/models/store/product_model.dart';
import 'package:sudan_goods/store/widgets/product_detail_bottom_sheet.dart';
import 'package:sudan_goods/store/widgets/product_grid_card.dart';
import 'package:sudan_goods/store/widgets/shimmer_product_grid_card.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

class CollectionProductsPage extends StatelessWidget {
  final Collection collection;

  const CollectionProductsPage({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartController>(context, listen: false);
    

    return Scaffold(
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
        title: Text(
          collection.name,
          style: AppTypography.heading6.copyWith(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list_rounded, color: Colors.black87),
            tooltip: 'Filter',
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('products')
                .where('storeId', isEqualTo: collection.storeId)
                .where('collectionIds', arrayContains: collection.id)
                .where('isAvailable', isEqualTo: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(DesignTokens.space20, DesignTokens.space16, DesignTokens.space20, DesignTokens.space16),
                  child: Text(
                    collection.name,
                    style: AppTypography.sectionTitle,
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: DesignTokens.paddingPageHorizontal,
                    itemCount: 6,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: DesignTokens.space12,
                      crossAxisSpacing: DesignTokens.space12,
                      childAspectRatio: 0.62,
                    ),
                    itemBuilder: (_, __) => const ShimmerProductGridCard(),
                  ),
                ),
              ],
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space20),
              child: Column(
                children: [
                  const SizedBox(height: DesignTokens.space24),
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: DesignTokens.space12),
                  Text('No products in this collection', style: AppTypography.bodyBold),
                  const SizedBox(height: DesignTokens.space8),
                  Text(
                    'Please check back later or browse other collections.',
                    style: AppTypography.small.copyWith(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final products =
              snapshot.data!.docs
                  .map((doc) => Product.fromDocument(doc))
                  .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(DesignTokens.space20, DesignTokens.space16, DesignTokens.space20, DesignTokens.space8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(collection.name, style: AppTypography.sectionTitle),
                    Text('${products.length} items', style: AppTypography.small.copyWith(color: Colors.black54)),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space20, vertical: DesignTokens.space12),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: DesignTokens.space12,
                    crossAxisSpacing: DesignTokens.space12,
                    childAspectRatio: 0.62,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Selector<CartController, int>(
                      selector: (_, c) => c.getProductQuantity(product.storeId, product.id),
                      builder: (context, qty, _) {
                        return ProductGridCard(
                          key: ValueKey(product.id),
                          product: product,
                          onTap: () {
                            showProductDetailsBottomSheet(context, product);
                          },
                          onAdd: () {
                            cart.addItem(
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
                          cartQuantity: qty,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
       // minimum: const EdgeInsets.only(bottom: 32),
        child:  FloatingCartBar(storeId: collection.storeId,),
      ),
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
