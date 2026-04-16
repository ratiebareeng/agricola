import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:flutter/material.dart';

class TimelineView extends StatelessWidget {
  final DateTime plantingDate;
  final DateTime expectedHarvestDate;
  final DateTime currentDate;

  TimelineView({
    super.key,
    required this.plantingDate,
    required this.expectedHarvestDate,
    DateTime? currentDate,
  }) : currentDate = currentDate ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    final totalDays = expectedHarvestDate.difference(plantingDate).inDays;
    final daysPassed = currentDate.difference(plantingDate).inDays;
    final progress = (daysPassed / totalDays).clamp(0.0, 1.0);

    return AgriFocusCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              _buildTimelineNode(
                icon: Icons.eco,
                color: AppColors.forestGreen,
                isActive: true,
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.bone,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.forestGreen,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildTimelineNode(
                icon: Icons.agriculture,
                color: progress >= 1.0 ? AppColors.forestGreen : AppColors.deepEmerald.withValues(alpha: 0.1),
                isActive: progress >= 1.0,
                iconColor: progress >= 1.0 ? Colors.white : AppColors.deepEmerald.withValues(alpha: 0.3),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PLANTED',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.deepEmerald.withValues(alpha: 0.4), letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(plantingDate),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepEmerald,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.forestGreen,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'HARVEST',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.deepEmerald.withValues(alpha: 0.4), letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(expectedHarvestDate),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepEmerald,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode({
    required IconData icon,
    required Color color,
    required bool isActive,
    Color iconColor = Colors.white,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
