import 'package:agricola/core/widgets/skeleton_primitives.dart';
import 'package:flutter/material.dart';

class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonBox(width: 30, height: 30, borderRadius: 8),
                const SkeletonBox(width: 40, height: 18, borderRadius: 10),
              ],
            ),
            const Spacer(),
            const SkeletonLine(width: 60, height: 22),
            const SizedBox(height: 2),
            const SkeletonLine(width: 80, height: 11),
          ],
        ),
      ),
    );
  }
}
