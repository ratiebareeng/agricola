import 'package:flutter/material.dart';

class QualitySelector extends StatelessWidget {
  final String? selectedQuality;
  final Function(String) onQualitySelected;

  const QualitySelector({
    super.key,
    required this.selectedQuality,
    required this.onQualitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QualityOption(
            label: 'Good',
            icon: Icons.sentiment_very_satisfied,
            color: Colors.green,
            isSelected: selectedQuality == 'good',
            onTap: () => onQualitySelected('good'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QualityOption(
            label: 'Fair',
            icon: Icons.sentiment_neutral,
            color: Colors.orange,
            isSelected: selectedQuality == 'fair',
            onTap: () => onQualitySelected('fair'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QualityOption(
            label: 'Poor',
            icon: Icons.sentiment_dissatisfied,
            color: Colors.red,
            isSelected: selectedQuality == 'poor',
            onTap: () => onQualitySelected('poor'),
          ),
        ),
      ],
    );
  }
}

class _QualityOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _QualityOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey[400], size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
