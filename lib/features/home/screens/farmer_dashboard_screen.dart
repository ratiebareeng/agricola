import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/providers/nav_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:agricola/features/crops/crop_helpers.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:agricola/features/crops/providers/crop_catalog_provider.dart';
import 'package:agricola/features/crops/providers/crop_providers.dart';
import 'package:agricola/features/crops/screens/add_edit_crop_screen.dart';
import 'package:agricola/features/crops/screens/crop_details_screen.dart';
import 'package:agricola/features/home/widgets/crop_card.dart';
import 'package:agricola/features/home/widgets/crop_card_skeleton.dart';
import 'package:agricola/features/home/widgets/hero_card_skeleton.dart';
import 'package:agricola/features/loss_calculator/screens/loss_calculator_screen.dart';
import 'package:agricola/features/notifications/providers/notifications_provider.dart';
import 'package:agricola/features/notifications/screens/notifications_screen.dart';
import 'package:agricola/features/orders/screens/orders_screen.dart';
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'YOUR FARM AT A GLANCE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            color: AppColors.forestGreen.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _FarmerNotificationBell(),
                ],
              ),
              const SizedBox(height: 32),

              // Hero Focus Card
              cropsAsync.when(
                data: (crops) => _buildHeroCard(context, crops, currentLang),
                loading: () => const HeroCardSkeleton(),
                error: (_, __) => _buildHeroCard(context, [], currentLang),
              ),
              const SizedBox(height: 32),

              // Quick Actions Row
              Row(
                children: [
                  Expanded(
                    child: AgriStadiumButton(
                      label: t('calculate_losses', currentLang),
                      onPressed: () => _openLossCalculator(context),
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AgriStadiumButton(
                      label: t('my_orders', currentLang),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const OrdersScreen(showSalesTab: true),
                        ),
                      ),
                      isPrimary: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // My Crops Section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t('my_crops', currentLang),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(selectedTabProvider.notifier).state = 2; // Crops tab
                    },
                    child: Text(
                      t('view_all', currentLang).toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        fontSize: 12,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 20),

              // Add New Crop Button - Now a bold Primary Stadium
              AgriStadiumButton(
                onPressed: () => _onAddCrop(context, ref),
                icon: Icons.add,
                label: t('add_new_crop', currentLang),
              ),
              const SizedBox(height: 24),

              // Crops List
              cropsAsync.when(
                data: (crops) =>
                    _buildCropsList(context, crops.take(3).toList(), imageMap),
                loading: () => Column(
                  children: List.generate(3, (_) => const CropCardSkeleton()),
                ),
                error: (error, _) => Center(
                  child: Text(
                    'Failed to load crops',
                    style: TextStyle(
                      color: AppColors.deepEmerald.withValues(alpha: 0.5),
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

  Widget _buildCropsList(
    BuildContext context,
    List<CropModel> crops,
    Map<String, String> imageMap,
  ) {
    if (crops.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(
                Icons.agriculture_outlined,
                size: 64,
                color: AppColors.deepEmerald.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 16),
              Text(
                'No crops planted yet.',
                style: TextStyle(
                  color: AppColors.deepEmerald.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w700,
                ),
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

  Widget _buildHeroCard(
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

    return AgriFocusCard(
      color: AppColors.deepEmerald,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AgriMetricDisplay(
                value: '${crops.length}',
                label: t('total_fields', lang),
                valueColor: AppColors.bone,
                labelColor: AppColors.bone.withValues(alpha: 0.5),
              ),
              AgriMetricDisplay(
                value: '$upcomingCount',
                label: 'HARVESTS', // Custom label for bold look
                valueColor: AppColors.earthYellow,
                labelColor: AppColors.earthYellow.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Divider(color: AppColors.bone.withValues(alpha: 0.1)),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.bone, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  upcomingCount > 0
                      ? 'You have $upcomingCount harvest${upcomingCount > 1 ? 's' : ''} coming up this month.'
                      : 'Everything is quiet. Time to plan your next field?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.bone.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
            color: AppColors.deepEmerald,
            size: 28,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.earthYellow,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.deepEmerald,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
