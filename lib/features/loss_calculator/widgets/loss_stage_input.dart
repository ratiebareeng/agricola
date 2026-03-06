import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/loss_calculator/loss_calculator_helpers.dart';
import 'package:flutter/material.dart';

class LossStageInput extends StatelessWidget {
  final String stage;
  final String unit;
  final AppLanguage lang;
  final TextEditingController amountController;
  final String? selectedCause;
  final ValueChanged<String?> onCauseChanged;
  final IconData icon;
  final Color color;

  const LossStageInput({
    super.key,
    required this.stage,
    required this.unit,
    required this.lang,
    required this.amountController,
    required this.selectedCause,
    required this.onCauseChanged,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final causes = lossCausesPerStage[stage] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                t('loss_stage_$stage', lang),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0.0',
                    suffixText: t(unit, lang),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF2D6A4F),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedCause,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: t('select_cause', lang),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF2D6A4F),
                  width: 2,
                ),
              ),
            ),
            items: causes.map((cause) {
              return DropdownMenuItem(
                value: cause,
                child: Text(t(cause, lang)),
              );
            }).toList(),
            onChanged: onCauseChanged,
          ),
        ],
      ),
    );
  }
}
