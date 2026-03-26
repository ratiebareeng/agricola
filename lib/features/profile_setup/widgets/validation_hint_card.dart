import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StepValidationHelper extends ConsumerWidget {
  final int step;
  final String userType;

  const StepValidationHelper({
    super.key,
    required this.step,
    required this.userType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    if (userType == 'farmer') {
      switch (step) {
        case 1:
          return ValidationHintCard(
            message: t('select_at_least_one_crop', currentLang),
            icon: Icons.agriculture,
          );
        case 2:
          return ValidationHintCard(
            message: t('select_farm_size_hint', currentLang),
            icon: Icons.landscape,
          );
        case 3:
          return ValidationHintCard(
            message: t('photo_optional_hint', currentLang),
            icon: Icons.camera_alt,
          );
        default:
          return const SizedBox.shrink();
      }
    }

    return const SizedBox.shrink();
  }
}

class ValidationHintCard extends ConsumerWidget {
  final String message;
  final IconData icon;

  const ValidationHintCard({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.mediumGray),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.mediumGray),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
