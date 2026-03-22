import 'package:agricola/core/widgets/skeleton_primitives.dart';
import 'package:flutter/material.dart';

class InventoryItemCardSkeleton extends StatelessWidget {
  const InventoryItemCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ShimmerWrapper(
        child: Column(
          children: [
            Row(
              children: [
                const SkeletonBox(width: 56, height: 56, borderRadius: 12),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonLine(width: 120, height: 18),
                      const SizedBox(height: 4),
                      const SkeletonLine(width: 80, height: 16),
                    ],
                  ),
                ),
                const SkeletonBox(width: 70, height: 28, borderRadius: 20),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(child: const SkeletonLine(width: 100, height: 12)),
                  const SizedBox(width: 12),
                  const SkeletonLine(width: 80, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
