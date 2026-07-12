import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCollectionCard extends StatelessWidget {
  const ShimmerCollectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: Container(width: double.infinity, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Container(height: 12, width: 60, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
