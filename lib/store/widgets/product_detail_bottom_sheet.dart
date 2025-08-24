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
    final int? discountPercent = hasDiscount
        ? (100 - ((product.discountPrice! / product.price) * 100)).round()
        : null;

    return SafeArea(
      child: Container(
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

            // 🖼️ Image Carousel with overlays
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

                    // Top-left discount or stock badge
                    if (hasDiscount && discountPercent != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.95),
                                AppColors.primary.withOpacity(0.75),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Text(
                            '-$discountPercent%',
                            style: AppTypography.smallBold.copyWith(color: Colors.white),
                          ),
                        ),
                      )
                    else if (isOutOfStock)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: LinearGradient(
                              colors: [Colors.grey.shade700, Colors.grey.shade500],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Text(
                            'OUT',
                            style: AppTypography.smallBold.copyWith(color: Colors.white),
                          ),
                        ),
                      ),

                    // Top-right close bubble
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 34,
                          height: 34,
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
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                            ],
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                        ),
                      ),
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

            // Meta chips (modern pill + gradient icon bubbles)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MetaChip(
                  icon: Icons.fitness_center,
                  label: '${product.weight} kg',
                ),
                const SizedBox(width: DesignTokens.space8),
                _MetaChip(
                  icon: isOutOfStock ? Icons.remove_shopping_cart : Icons.inventory_2_rounded,
                  label: isOutOfStock ? 'Out of stock' : 'In stock: ${product.quantity}',
                  gradientColors: isOutOfStock
                      ? [Colors.grey.shade700, Colors.grey.shade500]
                      : null,
                ),
              ],
            ),

            const SizedBox(height: DesignTokens.space12),

            // 💰 Price and Discount (gradient pill when discounted)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasDiscount) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.95),
                          AppColors.primary.withOpacity(0.75),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Text(
                      '€${price.toStringAsFixed(2)}',
                      style: AppTypography.bodyBold.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space8),
                  Text(
                    '€${product.price.toStringAsFixed(2)}',
                    style: AppTypography.small.copyWith(
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ] else ...[
                  Text(
                    '€${price.toStringAsFixed(2)}',
                    style: AppTypography.bodyBold,
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
                // Quantity stepper (gradient bubbles)
                IgnorePointer(
                  ignoring: isOutOfStock,
                  child: Opacity(
                    opacity: isOutOfStock ? 0.6 : 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: quantity > 1 ? () => setState(() => quantity--) : null,
                            child: Container(
                              width: 28,
                              height: 28,
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
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                                ],
                              ),
                              child: const Icon(Icons.remove, size: 18, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(quantity.toString(), style: AppTypography.bodyBold),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => setState(() => quantity++),
                            child: Container(
                              width: 28,
                              height: 28,
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
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                                ],
                              ),
                              child: const Icon(Icons.add, size: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: DesignTokens.space16),

                // Add to Cart Button (full-width gradient CTA)
                Expanded(
                  child: IgnorePointer(
                    ignoring: isOutOfStock,
                    child: Opacity(
                      opacity: isOutOfStock ? 0.6 : 1,
                      child: GestureDetector(
                        onTap: () {
                          if (isOutOfStock) return;
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.95),
                                AppColors.primary.withOpacity(0.75),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isOutOfStock
                                ? 'Out of stock'
                                : 'Add €${(price * quantity).toStringAsFixed(2)}',
                            style: AppTypography.bodyLarge.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color>? gradientColors;

  const _MetaChip({
    required this.icon,
    required this.label,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors ?? [
                  AppColors.primary.withOpacity(0.95),
                  AppColors.primary.withOpacity(0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Icon(icon, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.small),
        ],
      ),
    );
  }
}
