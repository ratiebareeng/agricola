import 'package:agricola/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AuthTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AuthTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.deepEmerald.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}
