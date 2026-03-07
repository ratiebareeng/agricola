import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/loss_calculator/loss_calculator_helpers.dart';
import 'package:agricola/features/loss_calculator/models/loss_calculation.dart';
import 'package:flutter/material.dart';

class LossResultsCard extends StatelessWidget {
  final LossCalculation calculation;
  final String cropCategory;
  final AppLanguage lang;

  const LossResultsCard({
    super.key,
    required this.calculation,
    required this.cropCategory,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final comparison = compareLossToRegional(calculation, cropCategory);
    final severityKey = lossSeverityKey(calculation.totalLossPercentage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary + Regional comparison side by side
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Loss percentage card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D6A4F),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t('your_loss', lang),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${calculation.totalLossPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${calculation.totalLoss.toStringAsFixed(1)} ${t(calculation.unit, lang)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          t(severityKey, lang),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Regional comparison card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t('region_avg', lang),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${comparison.regionalAverage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t('based_on_crop', lang),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Monetary impact
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _monetaryRow(
                t('total_harvest_value', lang),
                formatBWP(calculation.totalValue),
                Colors.black87,
              ),
              const Divider(height: 24),
              _monetaryRow(
                t('value_lost', lang),
                '- ${formatBWP(calculation.monetaryLoss)}',
                Colors.red,
              ),
              const Divider(height: 24),
              _monetaryRow(
                t('remaining_value', lang),
                formatBWP(calculation.remainingValue),
                const Color(0xFF2D6A4F),
                bold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Stage breakdown
        Text(
          t('loss_by_stage', lang),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        ...calculation.stages.where((s) => s.amount > 0).map(
              (stage) => _stageBreakdownRow(stage),
            ),

      ],
    );
  }

  Widget _monetaryRow(String label, String value, Color valueColor,
      {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _stageBreakdownRow(LossStage stage) {
    final pct = stage.percentage(calculation.harvestAmount);
    final stageColors = {
      'field': Colors.amber,
      'transport': Colors.blue,
      'storage': Colors.purple,
      'processing': Colors.teal,
    };
    final color = stageColors[stage.stage] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t('loss_stage_${stage.stage}', lang),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Text(
                '${stage.amount.toStringAsFixed(1)} ${t(calculation.unit, lang)} (${pct.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
          if (stage.cause != null) ...[
            const SizedBox(height: 6),
            Text(
              t(stage.cause!, lang),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}
