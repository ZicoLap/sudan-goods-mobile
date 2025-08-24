import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sudan_goods/models/store/product_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class ProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final int cartQuantity;

  const ProductGridCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAdd,
    this.cartQuantity = 0,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        product.discountPrice != null && product.discountPrice! > 0;
    final isOutOfStock = product.quantity == 0;

    return RepaintBoundary(
      child: SizedBox(
        height: 260,
        child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          onTap: onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(DesignTokens.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🖼️ Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: product.images.isNotEmpty ? product.images.first : '',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(color: Colors.white),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: Colors.grey.shade100,
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                              ),
                            ),
                            if (isOutOfStock)
                              Container(
                                color: Colors.black45,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Out of stock',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: DesignTokens.space8),

                    // 📦 Info: name, meta, price
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.cardTitle,
                          ),
                          Text(
                            '${product.weight} kg',
                            style: AppTypography.small,
                          ),
                          Text(
                            product.quantity > 0 ? '${product.quantity} in stock' : 'Out of stock',
                            style: AppTypography.small.copyWith(
                              color: isOutOfStock ? Colors.red : Colors.black87,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '€${(hasDiscount ? product.discountPrice! : product.price).toStringAsFixed(2)}',
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ➕ Add to cart button
              Positioned(
                top: 8,
                right: 8,
                child: IgnorePointer(
                  ignoring: isOutOfStock,
                  child: Opacity(
                    opacity: isOutOfStock ? 0.5 : 1,
                    child: GestureDetector(
                      onTap: isOutOfStock ? null : onAdd,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: cartQuantity > 0
                            ? Container(
                                width: 20,
                                height: 20,
                                alignment: Alignment.center,
                                child: Text(
                                  '$cartQuantity',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.add,
                                size: 20,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ),
              ),

              // Out of stock badge
              if (isOutOfStock)
                const Positioned(
                  top: 8,
                  left: 8,
                  child: Chip(
                    label: Text('Out of stock'),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
