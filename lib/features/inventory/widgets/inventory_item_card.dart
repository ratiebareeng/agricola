import 'package:agricola/core/providers/language_provider.dart';
import 'package:flutter/material.dart';

class InventoryItemCard extends StatelessWidget {
  final String cropType;
  final double quantity;
  final String unit;
  final DateTime storageDate;
  final String storageLocation;
  final String condition;
  final AppLanguage language;
  final VoidCallback? onTap;

  const InventoryItemCard({
    super.key,
    required this.cropType,
    required this.quantity,
    required this.unit,
    required this.storageDate,
    required this.storageLocation,
    required this.condition,
    required this.language,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final conditionColor = _getConditionColor();
    final daysInStorage = _getDaysInStorage();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: conditionColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: conditionColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    color: conditionColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t(cropType, language),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$quantity ${t(unit, language)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: conditionColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getConditionIcon(),
                        size: 14,
                        color: conditionColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        t(condition, language),
                        style: TextStyle(
                          color: conditionColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            storageLocation,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$daysInStorage ${t('days_in_storage', language)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConditionColor() {
    switch (condition.toLowerCase()) {
      case 'excellent':
      case 'good':
        return Colors.green;
      case 'fair':
      case 'needs_attention':
        return Colors.orange;
      case 'poor':
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getConditionIcon() {
    switch (condition.toLowerCase()) {
      case 'excellent':
      case 'good':
        return Icons.check_circle;
      case 'fair':
      case 'needs_attention':
        return Icons.warning_amber;
      case 'poor':
      case 'critical':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  int _getDaysInStorage() {
    return DateTime.now().difference(storageDate).inDays;
  }
}
