import 'package:agricola/core/widgets/skeleton_primitives.dart';
import 'package:flutter/material.dart';

class CropCardSkeleton extends StatelessWidget {
  const CropCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        child: Row(
          children: [
            const SkeletonBox(width: 80, height: 80, borderRadius: 12),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SkeletonLine(width: 100, height: 16),
                      const SkeletonBox(width: 50, height: 22, borderRadius: 8),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SkeletonLine(width: 120, height: 12),
                  const SizedBox(height: 12),
                  const SkeletonBox(height: 6, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
