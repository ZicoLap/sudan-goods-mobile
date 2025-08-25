import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sudan_goods/models/store/product_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

class FeaturedProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;
  final int cartQuantity;

  const FeaturedProductCard({
    super.key,
    required this.product,
    required this.onAdd,
    this.cartQuantity = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOutOfStock = product.quantity == 0;
    final bool hasDiscount = product.discountPrice != null && product.discountPrice! > 0;
    final int? discountPercent = hasDiscount
        ? (100 - ((product.discountPrice! / product.price) * 100)).round()
        : null;

    return Container(
      width: 260,
      padding: const EdgeInsets.all(DesignTokens.space12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
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
                    const SizedBox(height: 6),
                    Text(
                      product.quantity > 0
                          ? '${product.weight}g • ${product.quantity} in stock'
                          : l10n.outOfStock,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.small.copyWith(
                        color: isOutOfStock ? Colors.black54 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (hasDiscount)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                              '€${product.discountPrice!.toStringAsFixed(2)}',
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
                child: Stack(
                  children: [
                    ColorFiltered(
                      colorFilter: ColorFilter.matrix(isOutOfStock
                          ? const <double>[
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0, 0, 0, 1, 0,
                            ]
                          : const <double>[
                              1, 0, 0, 0, 0,
                              0, 1, 0, 0, 0,
                              0, 0, 1, 0, 0,
                              0, 0, 0, 1, 0,
                            ]),
                      child: CachedNetworkImage(
                        imageUrl: product.images.isNotEmpty ? product.images.first : '',
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(width: 76, height: 76, color: Colors.white),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 76,
                          height: 76,
                          color: Colors.grey.shade100,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_outlined, size: 28, color: Colors.grey),
                        ),
                      ),
                    ),
                    // Badge on image (top-left)
                    if (hasDiscount && discountPercent != null)
                      PositionedDirectional(
                        top: 6,
                        start: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                            ],
                          ),
                          child: Text(
                            '-$discountPercent%',
                            style: AppTypography.smallBold.copyWith(color: Colors.white),
                          ),
                        ),
                      )
                    else if (isOutOfStock)
                      PositionedDirectional(
                        top: 6,
                        start: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: LinearGradient(
                              colors: [Colors.grey.shade700, Colors.grey.shade500],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                            ],
                          ),
                          child: Text(
                            l10n.outOfStock,
                            style: AppTypography.smallBold.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 24,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.06)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ➕ Add Button (top-right corner) — hidden when out of stock
          if (!isOutOfStock)
            PositionedDirectional(
              top: 8,
              end: 8,
              child: GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.all(6),
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
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: cartQuantity > 0
                      ? Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          child: Text(
                            '$cartQuantity',
                            style: AppTypography.smallBold.copyWith(color: Colors.white),
                          ),
                        )
                      : const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
