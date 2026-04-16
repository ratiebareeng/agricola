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
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Row(
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.deepEmerald.withValues(alpha: 0.4),
                  letterSpacing: 1.5,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.alertRed,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              if (tooltip != null) ...[
                const SizedBox(width: 8),
                InfoTooltip(message: tooltip!),
              ],
            ],
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              description!,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.deepEmerald.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}
