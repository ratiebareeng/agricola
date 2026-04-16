import 'dart:io';

import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/utils/image_utils.dart';
import 'package:agricola/core/utils/url_utils.dart';
import 'package:agricola/core/widgets/app_filter_chip_group.dart';
import 'package:agricola/core/widgets/app_form_layout.dart';
import 'package:agricola/core/widgets/app_form_section.dart';
import 'package:agricola/core/widgets/app_radio_group.dart';
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
  File? _newPhoto;

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

  final List<String> _farmSizes = [
    'Small (< 5 hectares)',
    'Medium (5-20 hectares)',
    'Large (> 20 hectares)',
  ];

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
              child: AppRadioGroup<String>(
                items: _farmSizes,
                selectedItem: _farmSize,
                itemLabelBuilder: (item) => item,
                onSelected: (value) {
                  if (!isLoading) setState(() => _farmSize = value);
                },
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

  @override
  void initState() {
    super.initState();
    _village = widget.profile.displayLocation;
    _selectedCrops = List.from(widget.profile.primaryCrops);
    _farmSize = widget.profile.farmSize;
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
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
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

    final file = File(image.path);
    final isValid = await ImageUtils.validateImage(file);

    if (!isValid && mounted) {
      _showErrorSnackBar('Image must be less than 5MB and in JPG/PNG format');
      return;
    }

    final compressed = await ImageUtils.compressProfileImage(file);
    setState(() => _newPhoto = compressed);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCrops.isEmpty) {
      _showErrorSnackBar('Please select at least one crop');
      return;
    }

    final updatedProfile = widget.profile.copyWith(
      village: _village,
      primaryCrops: _selectedCrops,
      farmSize: _farmSize,
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
