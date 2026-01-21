import 'dart:io';

import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/utils/image_utils.dart';
import 'package:agricola/core/widgets/app_buttons.dart';
import 'package:agricola/core/widgets/app_text_field.dart';
import 'package:agricola/features/profile/providers/profile_controller_provider.dart';
import 'package:agricola/features/profile_setup/models/farmer_profile_model.dart';
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
  late TextEditingController _villageController;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPhotoSection(isLoading, uploadProgress),
            const SizedBox(height: 32),
            _buildVillageField(),
            const SizedBox(height: 24),
            _buildFarmSizeSection(isLoading),
            const SizedBox(height: 24),
            _buildCropsSection(isLoading),
            const SizedBox(height: 32),
            AppPrimaryButton(
              label: isLoading ? 'Saving...' : 'Save Changes',
              onPressed: isLoading ? null : _saveProfile,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _villageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _villageController = TextEditingController(
      text: widget.profile.displayLocation,
    );
    _selectedCrops = List.from(widget.profile.primaryCrops);
    _farmSize = widget.profile.farmSize;
  }

  Widget _buildCropsSection(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Primary Crops (Select up to 5)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableCrops.map((crop) {
            final isSelected = _selectedCrops.contains(crop);
            return FilterChip(
              label: Text(crop),
              selected: isSelected,
              onSelected: isLoading
                  ? null
                  : (selected) {
                      setState(() {
                        if (selected && _selectedCrops.length < 5) {
                          _selectedCrops.add(crop);
                        } else {
                          _selectedCrops.remove(crop);
                        }
                      });
                    },
              selectedColor: AppColors.green.withAlpha(50),
              checkmarkColor: AppColors.green,
              backgroundColor: Colors.grey[200],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFarmSizeSection(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Farm Size',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ..._farmSizes.map((size) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(size),
            leading: Radio<String>(
              value: size,
              groupValue: _farmSize,
              onChanged: isLoading
                  ? null
                  : (value) {
                      if (value != null) setState(() => _farmSize = value);
                    },
              activeColor: AppColors.green,
            ),
            onTap: isLoading ? null : () => setState(() => _farmSize = size),
          );
        }),
      ],
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
                      : widget.profile.photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(widget.profile.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey[200],
                ),
                child: (_newPhoto == null && widget.profile.photoUrl == null)
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),
              if (uploadProgress != null && uploadProgress > 0)
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: uploadProgress,
                    backgroundColor: Colors.grey[300],
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
        const SizedBox(height: 8),
        Text(
          'Tap to change photo',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildVillageField() {
    return AppTextField(
      controller: _villageController,
      label: 'Village/Location',
      prefixIcon: Icons.location_on_outlined,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Village is required';
        if (value.length < 2) return 'Village name is too short';
        return null;
      },
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
      village: _villageController.text,
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.green),
    );
  }
}
