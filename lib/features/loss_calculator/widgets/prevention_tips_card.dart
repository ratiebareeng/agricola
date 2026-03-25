import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/loss_calculator/loss_calculator_helpers.dart';
import 'package:agricola/features/loss_calculator/models/loss_calculation.dart';

import 'package:flutter/material.dart';

class PreventionTipsCard extends StatelessWidget {
  final LossCalculation calculation;
  final AppLanguage lang;

  const PreventionTipsCard({
    super.key,
    required this.calculation,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final highestStage = calculation.highestLossStage;
    if (highestStage == null || calculation.totalLoss <= 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2D6A4F)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                t('no_losses_recorded', lang),
                style: const TextStyle(
                  color: Color(0xFF2D6A4F),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final tips = preventionTipKeys(
      highestStage.stage,
      calculation.storageMethod,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('prevention_tips', lang),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${t('based_on_highest_loss', lang)}: ${t('loss_stage_${highestStage.stage}', lang)}',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        ...tips.asMap().entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: Color(0xFF2D6A4F),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t(entry.value, lang),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
