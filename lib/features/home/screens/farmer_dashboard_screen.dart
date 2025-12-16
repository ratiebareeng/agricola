import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
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
                          // Toggle language
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

              // Quick Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  StatCard(
                    title: t('total_fields', currentLang),
                    value: '12',
                    icon: Icons.landscape,
                    color: Colors.green,
                  ),
                  StatCard(
                    title: t('upcoming_harvests', currentLang),
                    value: '3',
                    icon: Icons.agriculture,
                    color: Colors.orange,
                  ),
                  StatCard(
                    title: t('inventory_value', currentLang),
                    value: '\$12.5k',
                    icon: Icons.inventory_2,
                    color: Colors.blue,
                  ),
                  StatCard(
                    title: t('estimated_losses', currentLang),
                    value: '2.1%',
                    icon: Icons.warning_amber,
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // My Crops Section
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditCropScreen(),
                      ),
                    );
                  },
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

              // Crops List
              GestureDetector(
                onTap: () {
                  final sampleCrop = CropModel(
                    id: '1',
                    cropType: 'maize',
                    fieldName: 'Maize Field A',
                    fieldSize: 2.5,
                    fieldSizeUnit: 'hectares',
                    plantingDate: DateTime(2023, 10, 15),
                    expectedHarvestDate: DateTime(2024, 2, 12),
                    estimatedYield: 450,
                    yieldUnit: 'kg',
                    storageMethod: 'improved_storage',
                    notes: 'Good soil quality, using hybrid seeds',
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CropDetailsScreen(crop: sampleCrop),
                    ),
                  );
                },
                child: const CropCard(
                  name: 'Maize Field A',
                  stage: 'Vegetative',
                  plantedDate: 'Oct 15, 2023',
                  progress: 0.4,
                  imageUrl:
                      'https://images.unsplash.com/photo-1551754655-cd27e38d2076?q=80&w=2070&auto=format&fit=crop',
                ),
              ),
              const CropCard(
                name: 'Sorghum Plot',
                stage: 'Flowering',
                plantedDate: 'Sep 01, 2023',
                progress: 0.7,
                imageUrl:
                    'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?q=80&w=2070&auto=format&fit=crop',
              ),
              const CropCard(
                name: 'Beans Row',
                stage: 'Harvest Ready',
                plantedDate: 'Aug 20, 2023',
                progress: 0.95,
                imageUrl:
                    'https://images.unsplash.com/photo-1592982537447-6f2a6a0c7c18?q=80&w=2069&auto=format&fit=crop',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
