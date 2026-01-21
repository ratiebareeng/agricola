import 'dart:io';

import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/utils/image_utils.dart';
import 'package:agricola/core/widgets/app_buttons.dart';
import 'package:agricola/core/widgets/app_text_field.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/profile/providers/profile_controller_provider.dart';
import 'package:agricola/features/profile_setup/models/merchant_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class EditMerchantProfileScreen extends ConsumerStatefulWidget {
  final MerchantProfileModel profile;

  const EditMerchantProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditMerchantProfileScreen> createState() =>
      _EditMerchantProfileScreenState();
}

class _EditMerchantProfileScreenState
    extends ConsumerState<EditMerchantProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _businessNameController;
  late TextEditingController _locationController;
  late MerchantType _merchantType;
  late List<String> _selectedProducts;
  File? _newPhoto;

  final List<String> _agriShopProducts = [
    'Seeds',
    'Fertilizers',
    'Pesticides',
    'Farm Tools',
    'Irrigation Equipment',
    'Animal Feed',
    'Veterinary Supplies',
  ];

  final List<String> _supermarketProducts = [
    'Sorghum',
    'Maize',
    'Beans',
    'Groundnuts',
    'Millet',
    'Vegetables',
    'Fruits',
    'Livestock Products',
  ];

  List<String> get _availableProducts {
    return _merchantType == MerchantType.agriShop
        ? _agriShopProducts
        : _supermarketProducts;
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final isLoading = profileState.isLoading;
    final uploadProgress = profileState.uploadProgress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Business Profile'),
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
            _buildBusinessNameField(),
            const SizedBox(height: 16),
            _buildLocationField(),
            const SizedBox(height: 24),
            _buildMerchantTypeSection(isLoading),
            const SizedBox(height: 24),
            _buildProductsSection(isLoading),
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
    _businessNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController(
      text: widget.profile.businessName,
    );
    _locationController = TextEditingController(
      text: widget.profile.displayLocation,
    );
    _merchantType = widget.profile.merchantType;
    _selectedProducts = List.from(widget.profile.productsOffered);
  }

  Widget _buildBusinessNameField() {
    return AppTextField(
      controller: _businessNameController,
      label: 'Business Name',
      prefixIcon: Icons.business_outlined,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Business name is required';
        }
        if (value.length < 3) {
          return 'Business name must be at least 3 characters';
        }
        if (value.length > 100) {
          return 'Business name cannot exceed 100 characters';
        }
        return null;
      },
    );
  }

  Widget _buildLocationField() {
    return AppTextField(
      controller: _locationController,
      label: 'Location',
      prefixIcon: Icons.location_on_outlined,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Location is required';
        if (value.length < 2) return 'Location name is too short';
        return null;
      },
    );
  }

  Widget _buildMerchantTypeSection(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Agri Shop'),
          subtitle: const Text('Sell agricultural supplies and equipment'),
          leading: Radio<MerchantType>(
            value: MerchantType.agriShop,
            groupValue: _merchantType,
            onChanged: isLoading
                ? null
                : (value) {
                    if (value != null) {
                      setState(() {
                        _merchantType = value;
                        _selectedProducts.clear();
                      });
                    }
                  },
            activeColor: AppColors.green,
          ),
          onTap: isLoading
              ? null
              : () {
                  setState(() {
                    _merchantType = MerchantType.agriShop;
                    _selectedProducts.clear();
                  });
                },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Supermarket/Vendor'),
          subtitle: const Text('Buy produce from farmers'),
          leading: Radio<MerchantType>(
            value: MerchantType.supermarketVendor,
            groupValue: _merchantType,
            onChanged: isLoading
                ? null
                : (value) {
                    if (value != null) {
                      setState(() {
                        _merchantType = value;
                        _selectedProducts.clear();
                      });
                    }
                  },
            activeColor: AppColors.green,
          ),
          onTap: isLoading
              ? null
              : () {
                  setState(() {
                    _merchantType = MerchantType.supermarketVendor;
                    _selectedProducts.clear();
                  });
                },
        ),
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
                    ? const Icon(Icons.store, size: 60, color: Colors.grey)
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

  Widget _buildProductsSection(bool isLoading) {
    final maxProducts = _merchantType == MerchantType.agriShop ? 7 : 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _merchantType == MerchantType.agriShop
              ? 'Products Sold (Select up to $maxProducts)'
              : 'Products Purchased (Select up to $maxProducts)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableProducts.map((product) {
            final isSelected = _selectedProducts.contains(product);
            return FilterChip(
              label: Text(product),
              selected: isSelected,
              onSelected: isLoading
                  ? null
                  : (selected) {
                      setState(() {
                        if (selected &&
                            _selectedProducts.length < maxProducts) {
                          _selectedProducts.add(product);
                        } else {
                          _selectedProducts.remove(product);
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

    if (_selectedProducts.isEmpty) {
      _showErrorSnackBar('Please select at least one product');
      return;
    }

    final updatedProfile = widget.profile.copyWith(
      businessName: _businessNameController.text,
      location: _locationController.text,
      merchantType: _merchantType,
      productsOffered: _selectedProducts,
    );

    final error = await ref
        .read(profileControllerProvider.notifier)
        .updateMerchantProfileWithPhoto(
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
