import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:agricola/core/widgets/skeleton_primitives.dart';
import 'package:flutter/material.dart';

class HeroCardSkeleton extends StatelessWidget {
  const HeroCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: AgriFocusCard(
        color: AppColors.deepEmerald.withValues(alpha: 0.8),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(width: 40, height: 32, borderRadius: 8),
                    const SizedBox(height: 8),
                    const SkeletonLine(width: 80, height: 12),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SkeletonBox(width: 40, height: 32, borderRadius: 8),
                    const SizedBox(height: 8),
                    const SkeletonLine(width: 80, height: 12),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Divider(color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 24),
            Row(
              children: [
                const SkeletonCircle(size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: SkeletonLine(height: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
