import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/utils/error_utils.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/app_dialogs.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
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
import 'package:agricola/features/crops/widgets/timeline_view.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:agricola/features/inventory/providers/inventory_providers.dart';
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
    final catalogEntry = ref.watch(cropCatalogEntryProvider(crop.cropType)).valueOrNull;
    final harvestsState = ref.watch(harvestNotifierProvider(crop.id!));
    final status = _getCropStatus(crop);
    final currentStage = _getCurrentStage(crop);
    final now = DateTime.now();
    final daysSincePlanting = now.difference(crop.plantingDate).inDays;
    final daysUntilHarvest = crop.expectedHarvestDate.difference(now).inDays.clamp(0, 999);

    return Scaffold(
      appBar: AppBar(
        title: Text(crop.fieldName.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.deepEmerald),
            onPressed: () async {
              final result = await Navigator.push<CropModel>(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditCropScreen(existingCrop: crop),
                ),
              );
              if (result != null && context.mounted) {
                final error = await ref.read(cropNotifierProvider.notifier).updateCrop(result);
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t(error, currentLang)), backgroundColor: AppColors.alertRed),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.alertRed),
            onPressed: () => _showDeleteDialog(context, currentLang, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cropDisplayName(crop.cropType, catalog, currentLang),
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.landscape, size: 14, color: AppColors.forestGreen.withValues(alpha: 0.5)),
                          const SizedBox(width: 6),
                          Text(
                            '${crop.fieldSize} ${t(crop.fieldSizeUnit, currentLang).toUpperCase()}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.forestGreen.withValues(alpha: 0.5),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: status, lang: currentLang),
              ],
            ),
            const SizedBox(height: 32),

            TimelineView(
              plantingDate: crop.plantingDate,
              expectedHarvestDate: crop.expectedHarvestDate,
            ),
            const SizedBox(height: 16),
            AgriStadiumButton(
              label: t('calculate_losses', currentLang),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LossCalculatorScreen(preselectedCrop: crop),
                  ),
                );
              },
              isPrimary: false,
              icon: Icons.calculate_outlined,
            ),
            const SizedBox(height: 32),

            Text(
              t('crop_details', currentLang).toUpperCase(),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.deepEmerald.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                _DetailMetric(
                  label: t('days_since_planting', currentLang),
                  value: '$daysSincePlanting',
                ),
                _DetailMetric(
                  label: t('days_until_harvest', currentLang),
                  value: '$daysUntilHarvest',
                  valueColor: AppColors.earthYellow,
                ),
                _DetailMetric(
                  label: t('current_stage', currentLang),
                  value: t(currentStage, currentLang).toUpperCase(),
                  isSmallValue: true,
                ),
                _DetailMetric(
                  label: t('estimated_yield', currentLang),
                  value: '${AgriKit.formatQuantity(crop.estimatedYield)}${t(crop.yieldUnit, currentLang)}',
                  isSmallValue: true,
                ),
              ],
            ),

            if (catalogEntry?.dailyWaterMm != null) ...[
              const SizedBox(height: 32),
              _buildWaterFieldCard(catalogEntry!, crop, currentLang),
            ],

            const SizedBox(height: 32),
            AgriFocusCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(icon: Icons.inventory_2_outlined, label: t('storage_method', currentLang), value: t(crop.storageMethod, currentLang)),
                  if (crop.notes != null && crop.notes!.isNotEmpty) ...[
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                    _InfoRow(icon: Icons.notes, label: t('notes', currentLang), value: crop.notes!),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t('harvest_history', currentLang).toUpperCase(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.deepEmerald.withValues(alpha: 0.4)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            harvestsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text(t(errorKeyFromException(error), currentLang), style: const TextStyle(color: AppColors.alertRed)),
              data: (harvests) {
                if (harvests.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      t('no_harvest_history', currentLang),
                      style: TextStyle(fontSize: 14, color: AppColors.deepEmerald.withValues(alpha: 0.3), fontWeight: FontWeight.w600),
                    ),
                  );
                }
                return Column(
                  children: harvests.map((harvest) {
                    final date = '${_monthName(harvest.harvestDate.month)} ${harvest.harvestDate.day}, ${harvest.harvestDate.year}';
                    return HarvestHistoryCard(
                      date: date,
                      yield: '${AgriKit.formatQuantity(harvest.actualYield)} ${harvest.yieldUnit}',
                      quality: harvest.quality,
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AgriStadiumButton(
          onPressed: () => _onRecordHarvest(context, ref, currentLang),
          icon: Icons.agriculture,
          label: t('record_harvest', currentLang),
        ),
      ),
    );
  }

  Future<void> _onRecordHarvest(BuildContext context, WidgetRef ref, AppLanguage currentLang) async {
    final result = await Navigator.push<HarvestModel>(
      context,
      MaterialPageRoute(builder: (context) => RecordHarvestScreen(crop: crop)),
    );
    if (result != null && context.mounted) {
      final harvestError = await ref.read(harvestNotifierProvider(crop.id!).notifier).addHarvest(result);
      if (harvestError != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t(harvestError, currentLang)), backgroundColor: AppColors.alertRed),
        );
        return;
      }

      // Prompt to add to inventory
      if (!context.mounted) return;
      final netAmount = result.actualYield - (result.lossAmount ?? 0);
      if (netAmount > 0) {
        final cropName = cropDisplayName(crop.cropType, ref.read(cropCatalogProvider).valueOrNull ?? [], currentLang);
        final addToInventory = await AppDialogs.confirm(
          context,
          icon: Icons.inventory_2_outlined,
          title: t('add_to_inventory', currentLang),
          content: t('add_to_inventory_prompt', currentLang)
              .replaceAll('{amount}', AgriKit.formatQuantity(netAmount))
              .replaceAll('{unit}', t(result.yieldUnit, currentLang))
              .replaceAll('{crop}', cropName),
          cancelText: t('not_now', currentLang),
          actionText: t('add', currentLang),
        );
        if (addToInventory && context.mounted) {
          final inventoryItem = InventoryModel(
            cropType: crop.cropType,
            quantity: netAmount,
            unit: result.yieldUnit,
            storageDate: result.harvestDate,
            storageLocation: result.storageLocation,
            condition: _qualityToCondition(result.quality),
            notes: result.notes,
          );
          await ref.read(inventoryNotifierProvider.notifier).addInventory(inventoryItem);
        }
      }
    }
  }

  Widget _buildWaterFieldCard(CropCatalogEntry entry, CropModel crop, AppLanguage lang) {
    final fieldHa = _fieldSizeInHa(crop);
    final totalLitresPerDay = entry.dailyWaterMm! * fieldHa * 10000;
    final litresPerHour = totalLitresPerDay / 24;
    final plantCount = entry.plantPopulationPerHa != null ? (entry.plantPopulationPerHa! * fieldHa).round() : null;

    return AgriFocusCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('water_field_info', lang).toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.deepEmerald, letterSpacing: 1)),
          const SizedBox(height: 24),
          _waterRow(Icons.opacity, t('total_daily_water', lang), '${_numFmt.format(totalLitresPerDay.round())} L/DAY'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
          _waterRow(Icons.speed, t('hourly_pump_rate', lang), '${_numFmt.format(litresPerHour.round())} L/HR'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
          _waterRow(Icons.water_drop_outlined, t('water_rate', lang), '${entry.dailyWaterMm} MM/DAY'),
          if (plantCount != null) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
            _waterRow(Icons.grass, t('estimated_plants', lang), _numFmt.format(plantCount)),
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
    final totalDays = crop.expectedHarvestDate.difference(crop.plantingDate).inDays;
    final progress = daysSincePlanting / totalDays;

    if (progress >= 1.0) return 'ready';
    return 'growing';
  }

  String _getCurrentStage(CropModel crop) {
    final now = DateTime.now();
    final daysSincePlanting = now.difference(crop.plantingDate).inDays;
    final totalDays = crop.expectedHarvestDate.difference(crop.plantingDate).inDays;
    final progress = daysSincePlanting / totalDays;

    if (progress < 0.15) return 'germination';
    if (progress < 0.45) return 'vegetative';
    if (progress < 0.70) return 'flowering';
    if (progress < 0.95) return 'ripening';
    return 'harvest_ready';
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

  void _showDeleteDialog(BuildContext context, AppLanguage lang, WidgetRef ref) async {
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
        final error = await ref.read(cropNotifierProvider.notifier).deleteCrop(crop.id!);
        if (error != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t(error, lang)), backgroundColor: AppColors.alertRed),
          );
          return;
        }
      }
      if (context.mounted) {
        Navigator.pop(context); // close details
      }
    }
  }

  String _qualityToCondition(String quality) {
    switch (quality.toLowerCase()) {
      case 'excellent':
        return 'excellent';
      case 'good':
        return 'good';
      case 'fair':
        return 'fair';
      case 'poor':
        return 'needs_attention';
      default:
        return 'good';
    }
  }

  Widget _waterRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.forestGreen.withValues(alpha: 0.5)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.deepEmerald.withValues(alpha: 0.4), letterSpacing: 0.5),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.deepEmerald),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final AppLanguage lang;
  const _StatusBadge({required this.status, required this.lang});

  @override
  Widget build(BuildContext context) {
    final color = status == 'ready' ? AppColors.earthYellow : AppColors.forestGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        t(status, lang).toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isSmallValue;

  const _DetailMetric({required this.label, required this.value, this.valueColor, this.isSmallValue = false});

  @override
  Widget build(BuildContext context) {
    return AgriFocusCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallValue ? 16 : 24,
              fontWeight: FontWeight.w900,
              color: valueColor ?? AppColors.deepEmerald,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.deepEmerald.withValues(alpha: 0.4),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.forestGreen.withValues(alpha: 0.5)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.deepEmerald.withValues(alpha: 0.4), letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.deepEmerald),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
