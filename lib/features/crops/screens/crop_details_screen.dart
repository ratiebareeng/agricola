import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/utils/error_utils.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/app_dialogs.dart';
import 'package:agricola/features/crops/crop_helpers.dart';
import 'package:agricola/features/crops/models/crop_catalog_entry.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:agricola/features/crops/models/harvest_model.dart';
import 'package:agricola/features/crops/providers/crop_catalog_provider.dart';
import 'package:agricola/features/crops/providers/crop_providers.dart';
import 'package:agricola/features/crops/providers/harvest_providers.dart';
import 'package:agricola/features/crops/screens/add_edit_crop_screen.dart';
import 'package:agricola/features/crops/screens/record_harvest_screen.dart';
import 'package:agricola/features/crops/widgets/harvest_history_card.dart';
import 'package:agricola/features/crops/widgets/info_card.dart';
import 'package:agricola/features/crops/widgets/timeline_view.dart';
import 'package:agricola/features/loss_calculator/screens/loss_calculator_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CropDetailsScreen extends ConsumerWidget {
  static final _numFmt = NumberFormat('#,###');

  final CropModel crop;

  const CropDetailsScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final catalog = ref.watch(cropCatalogProvider).valueOrNull ?? [];
    final catalogEntry = ref
        .watch(cropCatalogEntryProvider(crop.cropType))
        .valueOrNull;
    final harvestsState = ref.watch(harvestNotifierProvider(crop.id!));
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
            onPressed: () async {
              final result = await Navigator.push<CropModel>(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditCropScreen(existingCrop: crop),
                ),
              );
              if (result != null && context.mounted) {
                final error = await ref
                    .read(cropNotifierProvider.notifier)
                    .updateCrop(result);
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t(error, currentLang)),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context, currentLang, ref),
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
                              cropDisplayName(
                                crop.cropType,
                                catalog,
                                currentLang,
                              ),
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
                      Text(
                        t(status, currentLang),
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TimelineView(
                    plantingDate: crop.plantingDate,
                    expectedHarvestDate: crop.expectedHarvestDate,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LossCalculatorScreen(preselectedCrop: crop),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calculate_outlined, size: 18),
                    label: Text(t('calculate_losses', currentLang)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2D6A4F),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFF2D6A4F)),
                    ),
                  ),
                ],
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
                    childAspectRatio: 1.5,
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
                  if (catalogEntry?.dailyWaterMm != null) ...[
                    const SizedBox(height: 20),
                    _buildWaterFieldCard(catalogEntry!, crop, currentLang),
                  ],
                  const SizedBox(height: 20),
                  // TODO: Add real weather data integration here in the future
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: Colors.blue.withAlpha(10),
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(color: Colors.blue.withAlpha(30)),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.wb_sunny, color: Colors.blue[700], size: 24),
                  //       const SizedBox(width: 12),
                  //       Expanded(
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Text(
                  //               t('weather', currentLang),
                  //               style: TextStyle(
                  //                 fontSize: 12,
                  //                 color: Colors.blue[900],
                  //                 fontWeight: FontWeight.w600,
                  //               ),
                  //             ),
                  //             const SizedBox(height: 4),
                  //             Text(
                  //               '28°C • Partly Cloudy • 60% Humidity',
                  //               style: TextStyle(
                  //                 fontSize: 14,
                  //                 color: Colors.blue[800],
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 20),
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
                  harvestsState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text(
                      t(errorKeyFromException(error), currentLang),
                      style: const TextStyle(color: Colors.red),
                    ),
                    data: (harvests) {
                      if (harvests.isEmpty) {
                        return Text(
                          t('no_harvest_history', currentLang),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        );
                      }
                      return Column(
                        children: harvests.map((harvest) {
                          final date =
                              '${_monthName(harvest.harvestDate.month)} ${harvest.harvestDate.day}, ${harvest.harvestDate.year}';
                          return HarvestHistoryCard(
                            date: date,
                            yield:
                                '${harvest.actualYield} ${harvest.yieldUnit}',
                            quality: harvest.quality,
                          );
                        }).toList(),
                      );
                    },
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
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.push<HarvestModel>(
              context,
              MaterialPageRoute(
                builder: (context) => RecordHarvestScreen(crop: crop),
              ),
            );
            if (result != null && context.mounted) {
              final error = await ref
                  .read(harvestNotifierProvider(crop.id!).notifier)
                  .addHarvest(result);
              if (error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t(error, currentLang)),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
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

  Widget _buildWaterFieldCard(
    CropCatalogEntry entry,
    CropModel crop,
    AppLanguage lang,
  ) {
    final fieldHa = _fieldSizeInHa(crop);
    final totalLitresPerDay = entry.dailyWaterMm! * fieldHa * 10000;
    final litresPerHour = totalLitresPerDay / 24;
    final plantCount = entry.plantPopulationPerHa != null
        ? (entry.plantPopulationPerHa! * fieldHa).round()
        : null;

    return Container(
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
          Text(
            t('water_field_info', lang),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),

          const SizedBox(height: 16),
          _waterRow(
            Icons.opacity,
            t('total_daily_water', lang),
            '${_numFmt.format(totalLitresPerDay.round())} L/day',
          ),
          const SizedBox(height: 12),
          _waterRow(
            Icons.speed,
            t('hourly_pump_rate', lang),
            '${_numFmt.format(litresPerHour.round())} L/hr',
          ),
          const SizedBox(height: 12),
          _waterRow(
            Icons.water_drop_outlined,
            t('water_rate', lang),
            '${entry.dailyWaterMm} mm/day',
          ),
          if (plantCount != null) ...[
            const SizedBox(height: 12),
            _waterRow(
              Icons.grass,
              t('estimated_plants', lang),
              _numFmt.format(plantCount),
            ),
          ],
        ],
      ),
    );
  }

  double _fieldSizeInHa(CropModel crop) {
    if (crop.fieldSizeUnit == 'Metres (m²)') {
      return crop.fieldSize / 10000;
    }
    return crop.fieldSize;
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
        return AppColors.green;
      case 'ready':
        return AppColors.green;
      case 'harvested':
        return AppColors.mediumGray;
      default:
        return AppColors.mediumGray;
    }
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }

  void _showDeleteDialog(
    BuildContext context,
    AppLanguage lang,
    WidgetRef ref,
  ) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: t('confirm_delete', lang),
      content: t('delete_crop_message', lang),
      cancelText: t('cancel', lang),
      actionText: t('delete', lang),
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      if (crop.id != null) {
        final error = await ref
            .read(cropNotifierProvider.notifier)
            .deleteCrop(crop.id!);
        if (error != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t(error, lang)),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      if (context.mounted) {
        Navigator.pop(context); // close details
      }
    }
  }

  Widget _waterRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}
