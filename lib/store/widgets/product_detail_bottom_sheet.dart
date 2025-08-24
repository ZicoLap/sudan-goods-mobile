import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sudan_goods/cart/cart_controller.dart';
import 'package:sudan_goods/models/store/cart_item_model.dart';
import 'package:sudan_goods/models/store/product_model.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

class ProductDetailsBottomSheet extends StatefulWidget {
  final Product product;

  const ProductDetailsBottomSheet({super.key, required this.product});

  @override
  State<ProductDetailsBottomSheet> createState() =>
      _ProductDetailsBottomSheetState();
}

class _ProductDetailsBottomSheetState extends State<ProductDetailsBottomSheet> {
  int quantity = 1;
  int currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isOutOfStock = product.quantity == 0;
    final hasDiscount =
        product.discountPrice != null && product.discountPrice! > 0;
    final price = hasDiscount ? product.discountPrice! : product.price;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          DesignTokens.space20,
          DesignTokens.space16,
          DesignTokens.space20,
          DesignTokens.space24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                ),
              ),
            ),

            const SizedBox(height: DesignTokens.space16),

            // 🖼️ Image Carousel
            ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              child: SizedBox(
                height: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount:
                          product.images.isNotEmpty ? product.images.length : 1,
                      onPageChanged: (index) {
                        setState(() {
                          currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final imageUrl =
                            product.images.isNotEmpty
                                ? product.images[index]
                                : null;
                        return imageUrl != null
                            ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              /*  loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(color: Colors.white),
                                  );
                                },
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade100,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                                ) */
                              placeholder:
                                  (context, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.white,
                                    ),
                                  ),
                              errorWidget:
                                  (_, __, ___) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade100,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_outlined,
                                      size: 28,
                                      color: Colors.grey,
                                    ),
                                  ),
                            )
                            : Container(
                              color: Colors.grey.shade100,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 64,
                                color: Colors.grey,
                              ),
                            );
                      },
                    ),
                    if (product.images.length > 1)
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            product.images.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: currentImageIndex == index ? 10 : 6,
                              height: currentImageIndex == index ? 10 : 6,
                              decoration: BoxDecoration(
                                color:
                                    currentImageIndex == index
                                        ? AppColors.primary
                                        : Colors.white70,
                                shape: BoxShape.circle,
                                boxShadow:
                                    currentImageIndex == index
                                        ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 4,
                                          ),
                                        ]
                                        : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: DesignTokens.space16),

            // 📦 Product Name
            Text(
              product.name,
              style: AppTypography.heading6,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: DesignTokens.space8),

            // Meta chips
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  label: Text(
                    '${product.weight} kg',
                    style: AppTypography.small,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: DesignTokens.space8),
                Chip(
                  label: Text(
                    isOutOfStock
                        ? 'Out of stock'
                        : 'In stock: ${product.quantity}',
                    style: AppTypography.small,
                  ),
                  backgroundColor:
                      isOutOfStock ? Colors.red.shade50 : Colors.green.shade50,
                  labelStyle: AppTypography.small.copyWith(
                    color: isOutOfStock ? Colors.red : Colors.green.shade700,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            const SizedBox(height: DesignTokens.space12),

            // 💰 Price and Discount
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '€${price.toStringAsFixed(2)}',
                  style: AppTypography.bodyBold.copyWith(
                    color: hasDiscount ? Colors.red : Colors.black,
                  ),
                ),
                if (hasDiscount) ...[
                  const SizedBox(width: DesignTokens.space8),
                  Text(
                    '€${product.price.toStringAsFixed(2)}',
                    style: AppTypography.small.copyWith(
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: DesignTokens.space16),

            // 📃 Description
            Text(
              product.description,
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: DesignTokens.space24),

            // ➖➕ Quantity + Add Button
            Row(
              children: [
                // Quantity stepper
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusRound,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed:
                            quantity > 1
                                ? () => setState(() => quantity--)
                                : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Text(quantity.toString(), style: AppTypography.bodyBold),
                      IconButton(
                        onPressed: () => setState(() => quantity++),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: DesignTokens.space16),

                // Add to Cart Button
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        isOutOfStock
                            ? null
                            : () {
                              final cart = Provider.of<CartController>(
                                context,
                                listen: false,
                              );
                              cart.addItem(
                                CartItem(
                                  productId: product.id,
                                  storeId: product.storeId,
                                  name: product.name,
                                  price: price,
                                  weight: product.weight,
                                  imageUrl:
                                      product.images.isNotEmpty
                                          ? product.images.first
                                          : null,
                                  quantity: quantity,
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isOutOfStock ? Colors.grey : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusRound,
                        ),
                      ),
                      elevation: 1,
                    ),
                    child: Text(
                      isOutOfStock
                          ? 'Out of stock'
                          : 'Add €${(price * quantity).toStringAsFixed(2)}',
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
