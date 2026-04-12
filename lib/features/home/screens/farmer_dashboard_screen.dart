import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/providers/nav_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/features/crops/crop_helpers.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:agricola/features/crops/providers/crop_catalog_provider.dart';
import 'package:agricola/features/crops/providers/crop_providers.dart';
import 'package:agricola/features/crops/screens/add_edit_crop_screen.dart';
import 'package:agricola/features/crops/screens/crop_details_screen.dart';
import 'package:agricola/features/home/widgets/crop_card.dart';
import 'package:agricola/features/home/widgets/crop_card_skeleton.dart';
import 'package:agricola/features/home/widgets/stat_card.dart';
import 'package:agricola/features/home/widgets/stat_card_skeleton.dart';
import 'package:agricola/features/loss_calculator/screens/loss_calculator_screen.dart';
import 'package:agricola/features/notifications/providers/notifications_provider.dart';
import 'package:agricola/features/notifications/screens/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FarmerDashboardScreen extends ConsumerWidget {
  const FarmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final cropsAsync = ref.watch(cropNotifierProvider);
    final imageMap = ref.watch(cropImageUrlProvider).valueOrNull ?? {};

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('welcome_message', currentLang),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Let\'s check your farm status',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _FarmerNotificationBell(),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Stats — derived from backend crops
              cropsAsync.when(
                data: (crops) => _buildStatsGrid(context, crops, currentLang),
                loading: () => _buildStatsSkeleton(),
                error: (_, __) => _buildStatsGrid(context, [], currentLang),
              ),
              const SizedBox(height: 20),

              // Loss Calculator quick action
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openLossCalculator(context),
                  icon: const Icon(Icons.calculate_outlined),
                  label: Text(t('calculate_losses', currentLang)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: AppColors.green),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // My Crops Section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t('my_crops', currentLang),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(selectedTabProvider.notifier).state =
                          2; // Crops tab
                    },
                    child: Text(t('view_all', currentLang)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Add New Crop Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _onAddCrop(context, ref),
                  icon: const Icon(Icons.add),
                  label: Text(t('add_new_crop', currentLang)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Crops List — from backend
              cropsAsync.when(
                data: (crops) =>
                    _buildCropsList(context, crops.take(3).toList(), imageMap),
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: List.generate(3, (_) => const CropCardSkeleton()),
                  ),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.alertRed),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load crops',
                          style: const TextStyle(color: AppColors.mediumGray),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Crop cards from backend data
  // ---------------------------------------------------------------------------
  Widget _buildCropsList(
    BuildContext context,
    List<CropModel> crops,
    Map<String, String> imageMap,
  ) {
    if (crops.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              const Icon(
                Icons.agriculture_outlined,
                size: 48,
                color: AppColors.mediumGray,
              ),
              const SizedBox(height: 12),
              Text(
                'No crops yet. Tap the button above to add one.',
                style: const TextStyle(color: AppColors.mediumGray),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: crops
          .map(
            (crop) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CropDetailsScreen(crop: crop),
                  ),
                );
              },
              child: CropCard(
                name: crop.fieldName,
                stage: cropStage(crop),
                plantedDate: formatCropDate(crop.plantingDate),
                progress: cropProgress(crop),
                imageUrl: imageUrlForCrop(crop.cropType, imageMap),
              ),
            ),
          )
          .toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Stats grid built from real crop data
  // ---------------------------------------------------------------------------
  Widget _buildStatsGrid(
    BuildContext context,
    List<CropModel> crops,
    AppLanguage lang,
  ) {
    final now = DateTime.now();
    final upcomingCount = crops
        .where(
          (c) =>
              c.expectedHarvestDate.isAfter(now) &&
              c.expectedHarvestDate.isBefore(now.add(const Duration(days: 30))),
        )
        .length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: t('total_fields', lang),
          value: '${crops.length}',
          icon: Icons.landscape,
          color: AppColors.green,
        ),
        StatCard(
          title: t('upcoming_harvests', lang),
          value: '$upcomingCount',
          icon: Icons.agriculture,
          color: AppColors.green,
        ),
        StatCard(title: t('inventory_value', lang), value: '—'),
        StatCard(
          title: t('estimated_losses', lang),
          value: '—',
          onTap: () => _openLossCalculator(context),
        ),
      ],
    );
  }

  Widget _buildStatsSkeleton() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: List.generate(4, (_) => const StatCardSkeleton()),
    );
  }

  /// Navigate to AddEditCropScreen and persist any new crops via the notifier.
  Future<void> _onAddCrop(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditCropScreen()),
    );

    if (result == null || !context.mounted) return;

    final notifier = ref.read(cropNotifierProvider.notifier);
    final crops = result is List ? result : [result];

    for (final crop in crops) {
      if (crop is CropModel) {
        final error = await notifier.addCrop(crop);
        if (error != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t(error, ref.read(languageProvider))),
              backgroundColor: AppColors.alertRed,
            ),
          );
          return;
        }
      }
    }
  }

  void _openLossCalculator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LossCalculatorScreen()),
    );
  }
}

class _FarmerNotificationBell extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(unreadNotificationCountProvider);

    return Stack(
      children: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.darkGray,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.alertRed,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
