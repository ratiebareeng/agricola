import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/loss_calculator/models/loss_calculation.dart';
import 'package:agricola/features/loss_calculator/widgets/loss_results_card.dart';
import 'package:agricola/features/loss_calculator/widgets/prevention_tips_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class LossDetailScreen extends ConsumerWidget {
  final LossCalculation calculation;

  const LossDetailScreen({super.key, required this.calculation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final cropCategory = calculation.cropCategory ?? 'default';
    final dateStr = calculation.calculationDate != null
        ? DateFormat.yMMMd().format(calculation.calculationDate!)
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(t(calculation.cropType, lang)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dateStr.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  dateStr,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ),
            LossResultsCard(
              calculation: calculation,
              cropCategory: cropCategory,
              lang: lang,
            ),
            const SizedBox(height: 24),
            PreventionTipsCard(
              calculation: calculation,
              lang: lang,
            ),
          ],
        ),
      ),
    );
  }
}
