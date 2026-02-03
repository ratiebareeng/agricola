import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:agricola/features/crops/providers/crop_providers.dart';
import 'package:agricola/features/crops/screens/add_edit_crop_screen.dart';
import 'package:agricola/features/crops/screens/crop_details_screen.dart';
import 'package:agricola/features/home/widgets/crop_card.dart';
import 'package:agricola/features/home/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FarmerDashboardScreen extends ConsumerWidget {
  const FarmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final cropsAsync = ref.watch(cropNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('welcome_message', currentLang),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Let\'s check your farm status',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          final newLang = currentLang == AppLanguage.english
                              ? AppLanguage.setswana
                              : AppLanguage.english;
                          ref
                              .read(languageProvider.notifier)
                              .setLanguage(newLang);
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Text(
                            currentLang == AppLanguage.english ? 'EN' : 'TN',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {},
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Stats — derived from backend crops
              cropsAsync.when(
                data: (crops) => _buildStatsGrid(crops, currentLang),
                loading: () => _buildStatsPlaceholder(),
                error: (_, __) => _buildStatsGrid([], currentLang),
              ),
              const SizedBox(height: 32),

              // My Crops Section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t('my_crops', currentLang),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
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
              const SizedBox(height: 16),

              // Crops List — from backend
              cropsAsync.when(
                data: (crops) => _buildCropsList(context, crops),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: CircularProgressIndicator(
                      color: Color(0xFF2D6A4F),
                    ),
                  ),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load crops',
                          style: TextStyle(color: Colors.grey[600]),
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
  // Stats grid built from real crop data
  // ---------------------------------------------------------------------------
  Widget _buildStatsGrid(List<CropModel> crops, AppLanguage lang) {
    final now = DateTime.now();
    final upcomingCount = crops
        .where(
          (c) =>
              c.expectedHarvestDate.isAfter(now) &&
              c.expectedHarvestDate
                  .isBefore(now.add(const Duration(days: 30))),
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
          color: Colors.green,
        ),
        StatCard(
          title: t('upcoming_harvests', lang),
          value: '$upcomingCount',
          icon: Icons.agriculture,
          color: Colors.orange,
        ),
        StatCard(
          title: t('inventory_value', lang),
          value: '—',
          icon: Icons.inventory_2,
          color: Colors.blue,
        ),
        StatCard(
          title: t('estimated_losses', lang),
          value: '—',
          icon: Icons.warning_amber,
          color: Colors.red,
        ),
      ],
    );
  }

  // Skeleton while crops are loading
  Widget _buildStatsPlaceholder() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: List.generate(
        4,
        (_) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
  Widget _buildCropsList(BuildContext context, List<CropModel> crops) {
    if (crops.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              const Icon(
                Icons.agriculture_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                'No crops yet. Tap the button above to add one.',
                style: TextStyle(color: Colors.grey[600]),
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
                stage: _cropStage(crop),
                plantedDate: _formatDate(crop.plantingDate),
                progress: _cropProgress(crop),
                imageUrl: _imageUrlForCrop(crop.cropType),
              ),
            ),
          )
          .toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Derive a growth-stage label from planting / harvest dates.
  String _cropStage(CropModel crop) {
    final progress = _cropProgress(crop);
    if (progress >= 0.66) return 'Harvest Ready';
    if (progress >= 0.33) return 'Flowering';
    return 'Vegetative';
  }

  /// Progress 0–1 based on how far through the growing period we are.
  double _cropProgress(CropModel crop) {
    final totalDays =
        crop.expectedHarvestDate.difference(crop.plantingDate).inDays;
    if (totalDays <= 0) return 1.0;
    final elapsed = DateTime.now().difference(crop.plantingDate).inDays;
    return (elapsed / totalDays).clamp(0.0, 1.0);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Map crop types to representative images. Falls back to a generic one.
  String _imageUrlForCrop(String cropType) {
    const images = {
      'maize':
          'https://images.unsplash.com/photo-1551754655-cd27e38d2076?q=80&w=2070&auto=format&fit=crop',
      'sorghum':
          'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?q=80&w=2070&auto=format&fit=crop',
      'beans':
          'https://images.unsplash.com/photo-1592982537447-6f2a6a0c7c18?q=80&w=2069&auto=format&fit=crop',
      'wheat':
          'https://images.unsplash.com/photo-1599091b9609544e4d5c61a878044f0076438309db88aa09cdc10da8897553?q=80&w=1974&auto=format&fit=crop',
      'tomatoes':
          'https://images.unsplash.com/photo-1490645935967-10de6ba17061?q=80&w=1974&auto=format&fit=crop',
      'groundnuts':
          'https://images.unsplash.com/photo-1604374894610-66a930d04661?q=80&w=1974&auto=format&fit=crop',
    };
    return images[cropType.toLowerCase()] ?? images['maize']!;
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
              content: Text('Failed to save crop: $error'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }
  }
}
