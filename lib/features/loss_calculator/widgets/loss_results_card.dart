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
        // Summary card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2D6A4F),
                const Color(0xFF2D6A4F).withAlpha(200),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                t('total_loss', lang),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${calculation.totalLossPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${calculation.totalLoss.toStringAsFixed(1)} ${t(calculation.unit, lang)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  t(severityKey, lang),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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

        // Regional comparison
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: comparison.isBelowAverage
                ? Colors.green.withAlpha(20)
                : Colors.orange.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: comparison.isBelowAverage
                  ? Colors.green.withAlpha(60)
                  : Colors.orange.withAlpha(60),
            ),
          ),
          child: Row(
            children: [
              Icon(
                comparison.isBelowAverage
                    ? Icons.trending_down
                    : Icons.trending_up,
                color: comparison.isBelowAverage ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comparison.isBelowAverage
                          ? t('below_regional_average', lang)
                          : t('above_regional_average', lang),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: comparison.isBelowAverage
                            ? Colors.green[800]
                            : Colors.orange[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${t('regional_average', lang)}: ${comparison.regionalAverage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
