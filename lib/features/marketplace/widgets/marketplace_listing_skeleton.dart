import 'package:agricola/core/widgets/skeleton_primitives.dart';
import 'package:flutter/material.dart';

class MarketplaceListingSkeleton extends StatelessWidget {
  const MarketplaceListingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ShimmerWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + location
            const SkeletonLine(width: 180, height: 18),
            const SizedBox(height: 4),
            Row(
              children: [
                const SkeletonBox(width: 14, height: 14),
                const SizedBox(width: 4),
                const SkeletonLine(width: 100, height: 13),
              ],
            ),
            const SizedBox(height: 12),
            // Description lines
            const SkeletonLine(height: 14),
            const SizedBox(height: 4),
            const SkeletonLine(width: 200, height: 14),
            const SizedBox(height: 12),
            // Category badge + quantity
            Row(
              children: [
                const SkeletonBox(width: 60, height: 24, borderRadius: 6),
                const SizedBox(width: 8),
                const SkeletonLine(width: 60, height: 13),
              ],
            ),
            const SizedBox(height: 12),
            // Price + seller
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonLine(width: 80, height: 20),
                const SkeletonLine(width: 90, height: 13),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
