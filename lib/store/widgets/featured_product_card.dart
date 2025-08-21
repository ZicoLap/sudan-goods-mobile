import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sudan_goods/models/store/product_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class FeaturedProductCard extends StatelessWidget {
  final Product product;

  const FeaturedProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.quantity == 0;

    return Container(
      width: 260,
      padding: const EdgeInsets.all(DesignTokens.space12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: DesignTokens.shadowSmall,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.cardTitle,
                    ),
                    const SizedBox(height: DesignTokens.space8),
                    Text(
                      product.quantity > 0
                          ? '${product.weight}g • ${product.quantity} in stock'
                          : 'Out of stock',
                      style: AppTypography.small.copyWith(
                        color: isOutOfStock ? Colors.red : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space12),
                    if (product.discountPrice != null && product.discountPrice! > 0)
                      Row(
                        children: [
                          Text(
                            '€${product.discountPrice!.toStringAsFixed(2)}',
                            style: AppTypography.bodyBold.copyWith(color: Colors.red),
                          ),
                          const SizedBox(width: DesignTokens.space8),
                          Text(
                            '€${product.price.toStringAsFixed(2)}',
                            style: AppTypography.small.copyWith(
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '€${product.price.toStringAsFixed(2)}',
                        style: AppTypography.bodyBold,
                      ),
                  ],
                ),
              ),

              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                child: Image.network(
                  product.images.isNotEmpty ? product.images.first : '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(width: 80, height: 80, color: Colors.white),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade100,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_outlined, size: 28, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),

          // ➕ Add Button (top-right corner)
          Positioned(
            top: -4,
            right: -4,
            child: IgnorePointer(
              ignoring: isOutOfStock,
              child: Opacity(
                opacity: isOutOfStock ? 0.5 : 1,
                child: GestureDetector(
                  onTap: () {
                    // TODO: Add to cart logic
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
