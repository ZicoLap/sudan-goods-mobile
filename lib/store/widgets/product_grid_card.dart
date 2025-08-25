import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sudan_goods/models/store/product_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final hasDiscount =
        product.discountPrice != null && product.discountPrice! > 0;
    final isOutOfStock = product.quantity == 0;
    final int? discountPercent = hasDiscount
        ? (100 - ((product.discountPrice! / product.price) * 100)).round()
        : null;

    return RepaintBoundary(
      child: Material(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          side: BorderSide(color: Colors.black.withOpacity(0.06)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          onTap: onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(DesignTokens.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
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
                            if (isOutOfStock)
                              Container(
                                color: Colors.black45,
                                alignment: Alignment.center,
                                child: Text(
                                  l10n.outOfStock,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // 📦 Info: name, meta, price
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.cardTitle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOutOfStock
                              ? l10n.outOfStock
                              : '${product.weight}g • ${product.quantity} in stock',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.small.copyWith(
                            color: isOutOfStock ? Colors.black54 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: hasDiscount
                              ? [
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
                                ]
                              : [
                                  Text(
                                    '€${product.price.toStringAsFixed(2)}',
                                    style: AppTypography.bodyBold,
                                  ),
                                ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ➕ Add to cart button — hidden when out of stock
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
                          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
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
                          : const Icon(
                              Icons.add,
                              size: 20,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),

              // Discount/Stock badge (top-left)
              if (hasDiscount && discountPercent != null)
                PositionedDirectional(
                  top: 8,
                  start: 8,
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
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Text(
                      '-$discountPercent%',
                      style: AppTypography.smallBold.copyWith(color: Colors.white),
                    ),
                  ),
                )
              else if (isOutOfStock)
                PositionedDirectional(
                  top: 8,
                  start: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade700, Colors.grey.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Text(
                      l10n.outOfStock,
                      style: AppTypography.smallBold.copyWith(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
