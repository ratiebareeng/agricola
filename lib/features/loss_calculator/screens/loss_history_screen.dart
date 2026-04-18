import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:agricola/core/widgets/app_dialogs.dart';
import 'package:agricola/features/loss_calculator/loss_calculator_helpers.dart';
import 'package:agricola/features/loss_calculator/models/loss_calculation.dart';
import 'package:agricola/features/loss_calculator/providers/loss_calculator_provider.dart';
import 'package:agricola/features/loss_calculator/screens/loss_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class LossHistoryScreen extends ConsumerWidget {
  const LossHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final calculationsAsync = ref.watch(lossCalculatorNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(t('loss_history', lang)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: calculationsAsync.when(
        data: (calculations) {
          if (calculations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    t('no_saved_calculations', lang),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: calculations.length,
            itemBuilder: (context, index) {
              return _CalculationCard(
                calculation: calculations[index],
                lang: lang,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LossDetailScreen(
                      calculation: calculations[index],
                    ),
                  ),
                ),
                onDelete: () => _confirmDelete(
                  context,
                  ref,
                  calculations[index],
                  lang,
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF2D6A4F)),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t('error_loading', lang),
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              AgriStadiumButton(
                onPressed: () => ref
                    .read(lossCalculatorNotifierProvider.notifier)
                    .loadCalculations(),
                label: t('retry', lang),
                isPrimary: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    LossCalculation calculation,
    AppLanguage lang,
  ) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: t('delete_calculation', lang),
      content: t('delete_calculation_confirm', lang),
      cancelText: t('cancel', lang),
      actionText: t('delete', lang),
      isDestructive: true,
    );

    if (confirmed && calculation.id != null) {
      ref
          .read(lossCalculatorNotifierProvider.notifier)
          .deleteCalculation(calculation.id!);
    }
  }
}

class _CalculationCard extends StatelessWidget {
  final LossCalculation calculation;
  final AppLanguage lang;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CalculationCard({
    required this.calculation,
    required this.lang,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = calculation.calculationDate != null
        ? DateFormat.yMMMd().format(calculation.calculationDate!)
        : '';
    final severityKey = lossSeverityKey(calculation.totalLossPercentage);
    final severityColor = _severityColor(calculation.totalLossPercentage);

    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    t(calculation.cropType, lang),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.grey[400],
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              dateStr,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statChip(
                  '${calculation.totalLossPercentage.toStringAsFixed(1)}%',
                  t(severityKey, lang),
                  severityColor,
                ),
                const SizedBox(width: 12),
                _statChip(
                  formatBWP(calculation.monetaryLoss),
                  t('value_lost', lang),
                  Colors.red,
                ),
                const SizedBox(width: 12),
                _statChip(
                  '${AgriKit.formatQuantity(calculation.totalLoss)} ${t(calculation.unit, lang)}',
                  t('total_loss', lang),
                  Colors.grey[700]!,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _severityColor(double pct) {
    if (pct <= 5) return AppColors.green;
    if (pct <= 15) return AppColors.warmYellow;
    if (pct <= 25) return AppColors.warmYellow;
    return AppColors.alertRed;
  }
}
