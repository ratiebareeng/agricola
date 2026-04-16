import 'dart:io';

import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/app_text_field.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/crops/providers/crop_catalog_provider.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:agricola/features/profile_setup/widgets/district_map_picker.dart';
import 'package:agricola/features/profile_setup/widgets/location_autocomplete_field.dart';
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
      key: ValueKey('business_name_${state.userType.name}_${state.merchantType?.name}_${state.currentStep}'),
      label: t('business_name', currentLang),
      hint: 'e.g. Fresh Produce Wholesalers',
      initialValue: state.businessName,
      onChanged: (value) => notifier.updateBusinessName(value),
    );
  }

  Widget _buildCropsStep(WidgetRef ref) {
    final state = ref.watch(profileSetupProvider);
    final notifier = ref.read(profileSetupProvider.notifier);
    final currentLang = ref.watch(languageProvider);
    final catalogByCategory = ref.watch(cropCatalogByCategoryProvider);

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
        catalogByCategory.when(
          data: (categoryMap) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categoryMap.entries.map((category) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(
                      t(category.key, currentLang),
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
                    children: category.value.map((entry) {
                      final isSelected =
                          state.selectedCrops.contains(entry.nameEn);
                      return FilterChip(
                        label: Text(entry.displayName(currentLang)),
                        selected: isSelected,
                        onSelected: (_) => notifier.toggleCrop(entry.nameEn),
                        selectedColor: AppColors.green.withAlpha(20),
                        checkmarkColor: AppColors.green,
                        labelStyle: TextStyle(
                          color:
                              isSelected ? AppColors.green : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.green
                              : Colors.grey[300]!,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }).toList(),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.green),
            ),
          ),
          error: (e, _) => Text(
            'Failed to load crops',
            style: TextStyle(color: Colors.red[700]),
          ),
        ),
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
    final currentValue = isFarmer ? state.village : state.location;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isFarmer ? t('select_village', currentLang) : t('select_location', currentLang),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        LocationAutocompleteField(
          key: ValueKey('location_autocomplete_$isFarmer'),
          initialValue: currentValue.isEmpty ? null : currentValue,
          label: '',
          hint: isFarmer ? 'Search your village or area' : 'Search your business location',
          onChanged: (value) => isFarmer
              ? notifier.updateVillage(value)
              : notifier.updateLocation(value),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await showModalBottomSheet<String>(
              context: ref.context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (_) => SizedBox(
                height: MediaQuery.of(ref.context).size.height * 0.75,
                child: DistrictMapPicker(
                  selectedLocation: currentValue.isEmpty ? null : currentValue,
                ),
              ),
            );
            if (picked != null) {
              if (isFarmer) {
                notifier.updateVillage(picked);
              } else {
                notifier.updateLocation(picked);
              }
            }
          },
          icon: const Icon(Icons.map_outlined, size: 18),
          label: Text(t('view_on_map', currentLang)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.green,
            side: const BorderSide(color: AppColors.green),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
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
    final state = ref.watch(profileSetupProvider);
    final notifier = ref.read(profileSetupProvider.notifier);
    final currentLang = ref.watch(languageProvider);

    final products = state.merchantType == MerchantType.agriShop
        ? [
            'Seeds',
            'Fertiliser',
            'Pesticides',
            'Tools',
            'Machinery',
            'Animal Feed',
            'Irrigation Equipment',
            'Farming Supplies',
          ]
        : [
            'Grains',
            'Vegetables',
            'Fruits',
            'Livestock Products',
            'Dairy',
            'Poultry',
            'Eggs',
            'Processed Foods',
          ];

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
