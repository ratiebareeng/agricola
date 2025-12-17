import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:agricola/features/crops/screens/add_edit_crop_screen.dart';
import 'package:agricola/features/crops/screens/crop_details_screen.dart';
import 'package:agricola/features/home/widgets/crop_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CropsScreen extends ConsumerWidget {
  const CropsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // My Crops Section
                  Text(
                    t('my_crops', currentLang),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
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
                          builder: (context) =>
                              CropDetailsScreen(crop: sampleCrop),
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
                  // Add padding to avoid being hidden by the button
                  const SizedBox(height: 80),
                ],
              ),
            ),

            // Add New Crop Button
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: SizedBox(
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
            ),
          ],
        ),
      ),
    );
  }
}
