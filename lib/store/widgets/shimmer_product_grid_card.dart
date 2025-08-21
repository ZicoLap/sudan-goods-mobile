import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

class ShimmerProductGridCard extends StatelessWidget {
  const ShimmerProductGridCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(DesignTokens.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.space8),

            // Name line
            Container(
              height: 12,
              width: double.infinity,
              color: Colors.white,
            ),
            const SizedBox(height: DesignTokens.space8),

            // Price line
            Container(
              height: 10,
              width: 80,
              color: Colors.white,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
