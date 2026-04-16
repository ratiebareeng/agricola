import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:flutter/material.dart';

class CropCard extends StatelessWidget {
  final String name;
  final String stage;
  final String plantedDate;
  final double progress;
  final String imageUrl;
  final bool isSynced;

  const CropCard({
    super.key,
    required this.name,
    required this.stage,
    required this.plantedDate,
    required this.progress,
    required this.imageUrl,
    this.isSynced = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: AgriFocusCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Image with high radius
            Hero(
              tag: 'crop_image_$name',
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: AppColors.bone,
                  image: imageUrl.isEmpty
                      ? null
                      : DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                          onError: (_, __) {},
                        ),
                ),
                child: imageUrl.isEmpty
                    ? const Icon(
                        Icons.agriculture_outlined,
                        color: AppColors.forestGreen,
                        size: 40,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontSize: 18,
                                color: AppColors.deepEmerald,
                              ),
                        ),
                      ),
                      if (!isSynced)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            size: 16,
                            color: AppColors.earthYellow,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stage.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.forestGreen.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Custom Progress Bar
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.bone,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.forestGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'PLANTED $plantedDate',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.deepEmerald.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
