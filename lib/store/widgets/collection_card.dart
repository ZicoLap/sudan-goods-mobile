import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sudan_goods/models/store/collection_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

class CollectionCard extends StatelessWidget {
  final Collection collection;
  final VoidCallback onTap;

  const CollectionCard({
    super.key,
    required this.collection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: DesignTokens.shadowSmall,
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        child: InkWell(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.space12),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusMedium,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl:
                              collection.imageUrl.isNotEmpty
                                  ? collection.imageUrl
                                  : '',
                          fit: BoxFit.cover,
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
                        ),
                        // Soft bottom fade for a polished look
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 40,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.06),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.space8),
                Text(
                  collection.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.cardTitle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
