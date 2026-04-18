import 'dart:io';

import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/utils/image_utils.dart';
import 'package:agricola/core/utils/url_utils.dart';
import 'package:agricola/core/widgets/app_filter_chip_group.dart';
import 'package:agricola/core/widgets/app_form_layout.dart';
import 'package:agricola/core/widgets/app_form_section.dart';
import 'package:agricola/core/widgets/app_text_field.dart';
import 'package:agricola/features/profile/providers/profile_controller_provider.dart';
import 'package:agricola/features/profile_setup/models/farmer_profile_model.dart';
import 'package:agricola/features/profile_setup/widgets/location_autocomplete_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class EditFarmerProfileScreen extends ConsumerStatefulWidget {
  final FarmerProfileModel profile;

  const EditFarmerProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditFarmerProfileScreen> createState() =>
      _EditFarmerProfileScreenState();
}

class _EditFarmerProfileScreenState
    extends ConsumerState<EditFarmerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _village;
  late List<String> _selectedCrops;
  late String _farmSize;
  late TextEditingController _phoneController;
  late TextEditingController _customFarmSizeController;
  File? _newPhoto;

  static const _farmSizes = [
    '< 1 Hectare',
    '1-5 Hectares',
    '5-10 Hectares',
    '10+ Hectares',
    'Other',
  ];

  final List<String> _availableCrops = [
    'Sorghum',
    'Maize',
    'Beans',
    'Groundnuts',
    'Millet',
    'Cowpeas',
    'Watermelon',
    'Sweet Reed',
    'Vegetables',
  ];

  @override
  void initState() {
    super.initState();
    _village = widget.profile.displayLocation;
    _selectedCrops = List.from(widget.profile.primaryCrops);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber ?? '');
    _customFarmSizeController = TextEditingController();

    final savedSize = widget.profile.farmSize;
    if (_farmSizes.contains(savedSize)) {
      _farmSize = savedSize;
    } else if (savedSize.isNotEmpty) {
      _farmSize = 'Other';
      _customFarmSizeController.text = savedSize;
    } else {
      _farmSize = '';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _customFarmSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final isLoading = profileState.isLoading;
    final uploadProgress = profileState.uploadProgress;

    return AppFormLayout(
      title: 'Edit Profile',
      submitLabel: isLoading ? 'Saving...' : 'Save Changes',
      isLoading: isLoading,
      onSubmit: isLoading ? null : _saveProfile,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildPhotoSection(isLoading, uploadProgress),
            const SizedBox(height: 32),
            AppFormSection(
              title: 'Phone Number',
              child: AppTextField(
                controller: _phoneController,
                label: '',
                hint: 'e.g. +267 71 234 567',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(height: 24),
            AppFormSection(
              title: 'Village/Location',
              isRequired: true,
              child: LocationAutocompleteField(
                initialValue: _village,
                label: '',
                hint: 'Search your village or area',
                onChanged: (value) => setState(() => _village = value),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Village is required';
                  if (value.length < 2) return 'Village name is too short';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 24),
            AppFormSection(
              title: 'Farm Size',
              child: Column(
                children: [
                  ..._farmSizes.map((size) {
                    final isSelected = _farmSize == size;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: isLoading ? null : () => setState(() => _farmSize = size),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? AppColors.green : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected ? AppColors.green.withAlpha(25) : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Text(
                                size,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
                  }),
                  if (_farmSize == 'Other') ...[
                    const SizedBox(height: 4),
                    AppTextField(
                      controller: _customFarmSizeController,
                      label: '',
                      hint: 'Describe your farm size',
                      validator: (value) {
                        if (_farmSize == 'Other' && (value == null || value.trim().isEmpty)) {
                          return 'Please describe your farm size';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppFormSection(
              title: 'Primary Crops',
              description: 'Select all crops you grow',
              child: AppFilterChipGroup<String>(
                items: _availableCrops,
                selectedItems: _selectedCrops,
                itemLabelBuilder: (item) => item,
                onSelected: (crop, selected) {
                  if (isLoading) return;
                  setState(() {
                    if (selected) {
                      _selectedCrops.add(crop);
                    } else {
                      _selectedCrops.remove(crop);
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(bool isLoading, double? uploadProgress) {
    return Column(
      children: [
        GestureDetector(
          onTap: isLoading ? null : _pickImage,
          child: Stack(
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.green, width: 3),
                  image: _newPhoto != null
                      ? DecorationImage(
                          image: FileImage(_newPhoto!),
                          fit: BoxFit.cover,
                        )
                      : isNetworkUrl(widget.profile.photoUrl)
                      ? DecorationImage(
                          image: NetworkImage(widget.profile.photoUrl!),
                          fit: BoxFit.cover,
                          onError: (_, __) {},
                        )
                      : null,
                  color: AppColors.lightGray.withAlpha(50),
                ),
                child: (_newPhoto == null && widget.profile.photoUrl == null)
                    ? const Icon(Icons.person, size: 60, color: AppColors.mediumGray)
                    : null,
              ),
              if (uploadProgress != null && uploadProgress > 0)
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: uploadProgress,
                    backgroundColor: AppColors.lightGray,
                    color: AppColors.green,
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Tap to change photo',
          style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image == null) return;

    final result = await ImageUtils.prepare(File(image.path), preset: ImagePreset.profile);
    if (!result.ok) {
      if (mounted) _showErrorSnackBar(result.errorKey == 'image_invalid_format'
          ? 'Invalid image. Please select a JPG or PNG file.'
          : 'Image is too large even after compression. Please choose a smaller photo.');
      return;
    }
    setState(() => _newPhoto = result.file!);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCrops.isEmpty) {
      _showErrorSnackBar('Please select at least one crop');
      return;
    }

    if (_farmSize.isEmpty) {
      _showErrorSnackBar('Please select a farm size');
      return;
    }

    final effectiveFarmSize = _farmSize == 'Other'
        ? _customFarmSizeController.text.trim()
        : _farmSize;

    final phone = _phoneController.text.trim();

    final updatedProfile = widget.profile.copyWith(
      village: _village,
      primaryCrops: _selectedCrops,
      farmSize: effectiveFarmSize,
      phoneNumber: phone.isEmpty ? null : phone,
    );

    final error = await ref
        .read(profileControllerProvider.notifier)
        .updateFarmerProfileWithPhoto(
          profile: updatedProfile,
          newPhoto: _newPhoto,
        );

    if (!mounted) return;

    if (error == null) {
      context.pop();
      _showSuccessSnackBar('Profile updated successfully');
    } else {
      _showErrorSnackBar(error);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.alertRed, behavior: SnackBarBehavior.floating),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.green, behavior: SnackBarBehavior.floating),
    );
  }
}
