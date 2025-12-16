import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:agricola/features/crops/screens/add_edit_crop_screen.dart';
import 'package:agricola/features/crops/screens/record_harvest_screen.dart';
import 'package:agricola/features/crops/widgets/harvest_history_card.dart';
import 'package:agricola/features/crops/widgets/info_card.dart';
import 'package:agricola/features/crops/widgets/timeline_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CropDetailsScreen extends ConsumerWidget {
  final CropModel crop;

  const CropDetailsScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final status = _getCropStatus(crop);
    final currentStage = _getCurrentStage(crop);
    final now = DateTime.now();
    final daysSincePlanting = now.difference(crop.plantingDate).inDays;
    final daysUntilHarvest = crop.expectedHarvestDate
        .difference(now)
        .inDays
        .clamp(0, 999);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(crop.fieldName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditCropScreen(existingCrop: crop),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context, currentLang),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t(crop.cropType, currentLang),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.landscape,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${crop.fieldSize} ${t(crop.fieldSizeUnit, currentLang)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          t(status, currentLang),
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TimelineView(
                plantingDate: crop.plantingDate,
                expectedHarvestDate: crop.expectedHarvestDate,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('crop_details', currentLang),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                    children: [
                      InfoCard(
                        label: t('days_since_planting', currentLang),
                        value: '$daysSincePlanting',
                        icon: Icons.calendar_today,
                      ),
                      InfoCard(
                        label: t('days_until_harvest', currentLang),
                        value: '$daysUntilHarvest',
                        icon: Icons.schedule,
                      ),
                      InfoCard(
                        label: t('current_stage', currentLang),
                        value: t(currentStage, currentLang),
                        icon: Icons.eco,
                      ),
                      InfoCard(
                        label: t('estimated_yield', currentLang),
                        value:
                            '${crop.estimatedYield} ${t(crop.yieldUnit, currentLang)}',
                        icon: Icons.agriculture,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wb_sunny, color: Colors.blue[700], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t('weather', currentLang),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[900],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '28°C • Partly Cloudy • 60% Humidity',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
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
                            const Icon(
                              Icons.inventory_2,
                              size: 18,
                              color: Color(0xFF2D6A4F),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              t('storage_method', currentLang),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t(crop.storageMethod, currentLang),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (crop.notes != null && crop.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
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
                              const Icon(
                                Icons.notes,
                                size: 18,
                                color: Color(0xFF2D6A4F),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t('notes', currentLang),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            crop.notes!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t('harvest_history', currentLang),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const HarvestHistoryCard(
                    date: 'May 15, 2024',
                    yield: '450 kg',
                    quality: 'Good',
                  ),
                  const HarvestHistoryCard(
                    date: 'January 20, 2024',
                    yield: '380 kg',
                    quality: 'Fair',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecordHarvestScreen(crop: crop),
              ),
            );
          },
          icon: const Icon(Icons.agriculture),
          label: Text(t('record_harvest', currentLang)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D6A4F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  String _getCropStatus(CropModel crop) {
    final now = DateTime.now();
    final daysSincePlanting = now.difference(crop.plantingDate).inDays;
    final totalDays = crop.expectedHarvestDate
        .difference(crop.plantingDate)
        .inDays;
    final progress = daysSincePlanting / totalDays;

    if (progress >= 1.0) return 'ready';
    return 'growing';
  }

  String _getCurrentStage(CropModel crop) {
    final now = DateTime.now();
    final daysSincePlanting = now.difference(crop.plantingDate).inDays;
    final totalDays = crop.expectedHarvestDate
        .difference(crop.plantingDate)
        .inDays;
    final progress = daysSincePlanting / totalDays;

    if (progress < 0.15) return 'germination';
    if (progress < 0.45) return 'vegetative';
    if (progress < 0.70) return 'flowering';
    if (progress < 0.95) return 'ripening';
    return 'harvest_ready';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'growing':
        return Colors.orange;
      case 'ready':
        return Colors.green;
      case 'harvested':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteDialog(BuildContext context, AppLanguage lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('confirm_delete', lang)),
        content: Text(t('delete_crop_message', lang)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('cancel', lang)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(t('delete', lang)),
          ),
        ],
      ),
    );
  }
}
