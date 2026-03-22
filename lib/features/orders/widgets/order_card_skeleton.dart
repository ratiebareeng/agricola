import 'package:agricola/core/widgets/skeleton_primitives.dart';
import 'package:flutter/material.dart';

class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ShimmerWrapper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID + status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SkeletonLine(width: 100, height: 16),
                  const SkeletonBox(width: 80, height: 28, borderRadius: 20),
                ],
              ),
              const SizedBox(height: 12),
              // Items + price row
              Row(
                children: [
                  const SkeletonBox(width: 16, height: 16),
                  const SizedBox(width: 8),
                  const SkeletonLine(width: 60, height: 14),
                  const Spacer(),
                  const SkeletonLine(width: 70, height: 16),
                ],
              ),
              const SizedBox(height: 8),
              // Date row
              Row(
                children: [
                  const SkeletonBox(width: 16, height: 16),
                  const SizedBox(width: 8),
                  const SkeletonLine(width: 80, height: 14),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
