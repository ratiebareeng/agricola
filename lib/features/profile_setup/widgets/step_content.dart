import 'dart:io';

import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/app_text_field.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class StepContent extends ConsumerWidget {
  final int step;
  final UserType userType;

  const StepContent({super.key, required this.step, required this.userType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userType == UserType.farmer) {
      return _buildFarmerStep(context, ref);
    } else {
      return _buildMerchantStep(context, ref);
    }
  }

  Widget _buildBusinessNameStep(WidgetRef ref) {
    final state = ref.watch(profileSetupProvider);
    final notifier = ref.read(profileSetupProvider.notifier);
    final currentLang = ref.watch(languageProvider);

    return AppTextField(
      label: t('business_name', currentLang),
      hint: 'e.g. Fresh Produce Wholesalers',
      initialValue: state.businessName,
      onChanged: (value) => notifier.updateBusinessName(value),
    );
  }

  Widget _buildCropsStep(WidgetRef ref) {
    final cropCategories = {
      'Grains': ['Maize', 'Sorghum', 'Millet', 'Wheat'],
      'Legumes': ['Beans', 'Cowpeas', 'Groundnuts'],
      'Vegetables': [
        'Tomatoes',
        'Onions',
        'Cabbage',
        'Spinach',
        'Carrots',
        'Peppers',
      ],
      'Fruits': ['Watermelon', 'Butternut', 'Pumpkin'],
    };

    final state = ref.watch(profileSetupProvider);
    final notifier = ref.read(profileSetupProvider.notifier);
    final currentLang = ref.watch(languageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('select_multiple', currentLang),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        ...cropCategories.entries.map((category) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text(
                  category.key,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: category.value.map((crop) {
                  final isSelected = state.selectedCrops.contains(crop);
                  return FilterChip(
                    label: Text(t(crop, currentLang)),
                    selected: isSelected,
                    onSelected: (_) => notifier.toggleCrop(crop),
                    selectedColor: AppColors.green.withAlpha(20),
                    checkmarkColor: AppColors.green,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.green : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.green : Colors.grey[300]!,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildFarmerStep(BuildContext context, WidgetRef ref) {
    switch (step) {
      case 0:
        return _buildLocationStep(ref, isFarmer: true);
      case 1:
        return _buildCropsStep(ref);
      case 2:
        return _buildFarmSizeStep(ref);
      case 3:
        return _buildPhotoStep(ref);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFarmSizeStep(WidgetRef ref) {
    final sizes = [
      '< 1 Hectare',
      '1-5 Hectares',
      '5-10 Hectares',
      '10+ Hectares',
    ];
    final state = ref.watch(profileSetupProvider);
    final notifier = ref.read(profileSetupProvider.notifier);
    final currentLang = ref.watch(languageProvider);

    return Column(
      children: sizes.map((size) {
        final isSelected = state.farmSize == size;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () => notifier.updateFarmSize(size),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? AppColors.green : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? AppColors.green.withAlpha(25)
                    : Colors.white,
              ),
              child: Row(
                children: [
                  Text(
                    t(size, currentLang),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected ? AppColors.green : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppColors.green),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationStep(WidgetRef ref, {required bool isFarmer}) {
    final state = ref.watch(profileSetupProvider);
    final notifier = ref.read(profileSetupProvider.notifier);
    final currentLang = ref.watch(languageProvider);

    if (isFarmer) {
      final villages = [
        'Gaborone',
        'Francistown',
        'Maun',
        'Serowe',
        'Molepolole',
        'Kanye',
        'Mochudi',
        'Mahalapye',
        'Palapye',
        'Tlokweng',
        'Ramotswa',
        'Mogoditshane',
        'Gabane',
        'Lobatse',
        'Thamaga',
        'Letlhakane',
        'Tonota',
        'Moshupa',
        'Jwaneng',
        'Ghanzi',
        'Other',
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('select_village', currentLang),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: state.village.isEmpty ? null : state.village,
                hint: Text(t('select_village', currentLang)),
                isExpanded: true,
                items: villages.map((village) {
                  return DropdownMenuItem(value: village, child: Text(village));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    notifier.updateVillage(value);
                  }
                },
              ),
            ),
          ),
          if (state.village == 'Other') ...[
            const SizedBox(height: 16),
            AppTextField(
              label: t('specify_location', currentLang),
              hint: 'Enter your village/area',
              initialValue: state.customVillage,
              onChanged: (value) => notifier.updateCustomVillage(value),
            ),
          ],
        ],
      );
    } else {
      return AppTextField(
        label: t('location', currentLang),
        hint: 'e.g. Gaborone Main Mall',
        initialValue: state.location,
        onChanged: (value) => notifier.updateLocation(value),
      );
    }
  }

  Widget _buildMerchantStep(BuildContext context, WidgetRef ref) {
    switch (step) {
      case 0:
        return _buildBusinessNameStep(ref);
      case 1:
        return _buildLocationStep(ref, isFarmer: false);
      case 2:
        return _buildProductsStep(ref);
      case 3:
        return _buildPhotoStep(ref);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPhotoStep(WidgetRef ref) {
    final state = ref.watch(profileSetupProvider);
    final currentLang = ref.watch(languageProvider);

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _pickImage(ref),
            child: Stack(
              children: [
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    image: state.photoPath != null
                        ? DecorationImage(
                            image: FileImage(File(state.photoPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: state.photoPath == null
                      ? const Icon(Icons.person, size: 80, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            state.photoPath == null
                ? t('tap_to_add_photo', currentLang)
                : t('tap_to_change_photo', currentLang),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _pickImage(ref),
            icon: const Icon(Icons.upload),
            label: Text(t('upload_photo', currentLang)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsStep(WidgetRef ref) {
    final products = [
      'Grains',
      'Vegetables',
      'Fruits',
      'Livestock',
      'Dairy',
      'Poultry',
    ];
    final state = ref.watch(profileSetupProvider);
    final notifier = ref.read(profileSetupProvider.notifier);
    final currentLang = ref.watch(languageProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: products.map((product) {
        final isSelected = state.selectedProducts.contains(product);
        return FilterChip(
          label: Text(t(product, currentLang)),
          selected: isSelected,
          onSelected: (_) => notifier.toggleProduct(product),
          selectedColor: AppColors.green.withAlpha(20),
          checkmarkColor: AppColors.green,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.green : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _pickImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final notifier = ref.read(profileSetupProvider.notifier);

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      notifier.setPhoto(image.path);
    }
  }
}
