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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.space12),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                  child: Image.network(
                    collection.imageUrl.isNotEmpty ? collection.imageUrl : '',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
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
                      child: const Icon(Icons.collections_outlined, color: Colors.grey, size: 28),
                    ),
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
    );
  }
}
