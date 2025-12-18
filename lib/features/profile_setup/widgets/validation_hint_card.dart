import 'package:agricola/core/providers/language_provider.dart';
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
            color: Colors.green[700],
          );
        case 2:
          return ValidationHintCard(
            message: t('select_farm_size_hint', currentLang),
            icon: Icons.landscape,
            color: Colors.amber[700],
          );
        case 3:
          return ValidationHintCard(
            message: t('photo_optional_hint', currentLang),
            icon: Icons.camera_alt,
            color: Colors.grey[600],
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
  final Color? color;

  const ValidationHintCard({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayColor = color ?? Colors.blue[600];

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: displayColor!.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: displayColor.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: displayColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: displayColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
