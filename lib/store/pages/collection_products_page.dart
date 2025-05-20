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

class CollectionProductsPage extends StatelessWidget {
  final Collection collection;

  const CollectionProductsPage({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartController>(context);
    

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          collection.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Text(
                    collection.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 6,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.5 / 3,
                        ),
                    itemBuilder: (_, __) => const ShimmerProductGridCard(),
                  ),
                ),
              ],
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Center(
                    /* child: Text(
                      collection.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ), */
                  ),
                ),
                const Expanded(
                  child: Center(child: Text('No products in this collection')),
                ),
              ],
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                /* child: Text(
                  collection.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ), */
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.62,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductGridCard(
                      product: product,
                      onTap: () {
                        // TODO: Open bottom sheet
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
                            imageUrl:
                                product.images.isNotEmpty
                                    ? product.images.first
                                    : null,
                            quantity: 1,
                          ),
                        );
                      },
                      cartQuantity: cart.getProductQuantity(product.storeId, product.id),
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
