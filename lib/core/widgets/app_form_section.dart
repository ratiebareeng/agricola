import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/info_tooltip.dart';
import 'package:flutter/material.dart';

class AppFormSection extends StatelessWidget {
  final String title;
  final String? description;
  final String? tooltip;
  final Widget child;
  final bool isRequired;

  const AppFormSection({
    super.key,
    required this.title,
    required this.child,
    this.description,
    this.tooltip,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: AppColors.alertRed,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (tooltip != null) ...[
              const SizedBox(width: 8),
              InfoTooltip(message: tooltip!),
            ],
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.mediumGray,
            ),
          ),
        ],
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
