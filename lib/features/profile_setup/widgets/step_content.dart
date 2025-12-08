import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/app_text_field.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final crops = [
      'Maize',
      'Sorghum',
      'Beans',
      'Watermelon',
      'Spinach',
      'Tomatoes',
      'Onions',
      'Cabbage',
    ];
    final state = ref.watch(profileSetupProvider);
    final notifier = ref.read(profileSetupProvider.notifier);
    final currentLang = ref.watch(languageProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: crops.map((crop) {
        final isSelected = state.selectedCrops.contains(crop);
        return FilterChip(
          label: Text(t(crop, currentLang)),
          selected: isSelected,
          onSelected: (_) => notifier.toggleCrop(crop),
          selectedColor: AppColors.green.withOpacity(0.2),
          checkmarkColor: AppColors.green,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.green : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
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
                    ? AppColors.green.withOpacity(0.05)
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

    return Column(
      children: [
        if (isFarmer) ...[
          AppTextField(
            label: t('village_area', currentLang),
            hint: 'e.g. Serowe',
            initialValue: state.village,
            onChanged: (value) => notifier.updateVillage(value),
          ),
        ] else ...[
          AppTextField(
            label: t('location', currentLang),
            hint: 'e.g. Gaborone Main Mall',
            initialValue: state.location,
            onChanged: (value) => notifier.updateLocation(value),
          ),
        ],
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
    final currentLang = ref.watch(languageProvider);
    return Center(
      child: Column(
        children: [
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              // Pick image logic
            },
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
          selectedColor: AppColors.green.withOpacity(0.2),
          checkmarkColor: AppColors.green,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.green : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
