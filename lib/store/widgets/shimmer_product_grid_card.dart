import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Name line
            Container(
              height: 12,
              width: double.infinity,
              color: Colors.white,
            ),
            const SizedBox(height: 6),

            // Price line
            Container(
              height: 10,
              width: 80,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
