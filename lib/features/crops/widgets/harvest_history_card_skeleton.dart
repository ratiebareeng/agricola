import 'package:agricola/core/widgets/skeleton_primitives.dart';
import 'package:flutter/material.dart';

class HarvestHistoryCardSkeleton extends StatelessWidget {
  const HarvestHistoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ShimmerWrapper(
        child: Row(
          children: [
            const SkeletonBox(width: 48, height: 48, borderRadius: 12),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLine(width: 100, height: 14),
                  const SizedBox(height: 4),
                  const SkeletonLine(width: 80, height: 12),
                ],
              ),
            ),
            const SkeletonBox(width: 60, height: 28, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}
