import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:flutter/material.dart';

class HarvestHistoryCard extends StatelessWidget {
  final String date;
  final String yield;
  final String quality;

  const HarvestHistoryCard({
    super.key,
    required this.date,
    required this.yield,
    required this.quality,
  });

  @override
  Widget build(BuildContext context) {
    Color qualityColor;
    switch (quality.toLowerCase()) {
      case 'excellent':
        qualityColor = AppColors.forestGreen;
        break;
      case 'good':
        qualityColor = AppColors.forestGreen;
        break;
      case 'fair':
        qualityColor = AppColors.earthYellow;
        break;
      case 'poor':
        qualityColor = AppColors.alertRed;
        break;
      default:
        qualityColor = AppColors.mediumGray;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AgriFocusCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bone,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.agriculture, color: AppColors.forestGreen, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.deepEmerald.withValues(alpha: 0.4),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    yield,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepEmerald,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: qualityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                quality.toUpperCase(),
                style: TextStyle(
                  color: qualityColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
