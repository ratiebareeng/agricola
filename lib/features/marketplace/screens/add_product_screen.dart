import 'dart:io';

import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/utils/image_utils.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:agricola/features/marketplace/models/marketplace_listing.dart';
import 'package:agricola/features/marketplace/providers/marketplace_provider.dart';
import 'package:agricola/features/profile/providers/profile_providers.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  final MarketplaceListing? existingProduct;
  final InventoryModel? sourceInventory;

  const AddProductScreen({
    super.key,
    this.existingProduct,
    this.sourceInventory,
  });

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  late List<String> _existingImageUrls;
  final List<File> _newImages = [];

  int get _totalImageCount => _existingImageUrls.length + _newImages.length;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;

  String _category = 'Vegetables';
  String _unit = 'kg';
  final _otherCategoryController = TextEditingController();

  final List<String> _categories = [
    'Vegetables',
    'Fruits',
    'Grains & Cereals',
    'Legumes',
    'Roots & Tubers',
    'Herbs & Spices',
    'Livestock',
    'Poultry',
    'Dairy & Eggs',
    'Seeds',
    'Fertilizers',
    'Pesticides',
    'Tools & Equipment',
    'Irrigation',
    'Animal Feed',
    'Packaging',
    'Processed Foods',
    'Other',
  ];

  final List<String> _units = [
    'kg',
    'g',
    'tons',
    'bags',
    'sacks',
    'crates',
    'litres',
    'ml',
    'pieces',
    'boxes',
    'bundles',
    'heads',
    'dozen',
    'bales',
    'trays',
  ];

  bool get _isEditing => widget.existingProduct != null;

  bool get _isFromInventory =>
      widget.sourceInventory != null && !_isEditing;

  @override
  void initState() {
    super.initState();
    final product = widget.existingProduct;
    final source = widget.sourceInventory;

    if (product != null) {
      // Editing existing listing
      _titleController = TextEditingController(text: product.title);
      _descriptionController =
          TextEditingController(text: product.description);
      _priceController =
          TextEditingController(text: product.price?.toString() ?? '');
      _quantityController =
          TextEditingController(text: product.quantity ?? '');
      _category = _categories.contains(product.category) ? product.category : 'Other';
      if (!_categories.contains(product.category)) {
        _otherCategoryController.text = product.category;
      }
      _unit = _units.contains(product.unit) ? (product.unit ?? 'kg') : 'kg';
      _existingImageUrls = [
        if (product.imagePath != null && product.imagePath!.isNotEmpty)
          product.imagePath!,
        ...?product.additionalImages,
      ];
    } else if (source != null) {
      // Pre-fill from inventory
      _titleController = TextEditingController(text: source.cropType);
      _descriptionController =
          TextEditingController(text: source.notes ?? '');
      _priceController = TextEditingController();
      _quantityController =
          TextEditingController(text: source.quantity.toString());
      _unit = _units.contains(source.unit) ? source.unit : 'kg';
      _existingImageUrls = List<String>.from(source.imageUrls);
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _priceController = TextEditingController();
      _quantityController = TextEditingController();
      _existingImageUrls = [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _otherCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? t('edit_product', currentLang) : t('add_product', currentLang),
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePicker(currentLang),
                    const SizedBox(height: 20),
                    if (_isFromInventory) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D6A4F).withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2D6A4F).withAlpha(50),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.inventory_2,
                              color: Color(0xFF2D6A4F),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t('listing_from_inventory', currentLang),
                                style: const TextStyle(
                                  color: Color(0xFF2D6A4F),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    _buildSectionTitle(t('product_name', currentLang)),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _titleController,
                      hint: t('enter_product_name', currentLang),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return t('required_field', currentLang);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle(t('description', currentLang)),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _descriptionController,
                      hint: t('enter_description', currentLang),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return t('required_field', currentLang);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle(t('category', currentLang)),
                    const SizedBox(height: 8),
                    _buildDropdownField(
                      value: _category,
                      items: _categories,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _category = value);
                        }
                      },
                    ),
                    if (_category == 'Other') ...[
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _otherCategoryController,
                        hint: 'Specify category (e.g. Mushrooms)',
                        validator: (value) {
                          if (_category == 'Other' && (value == null || value.isEmpty)) {
                            return t('required_field', currentLang);
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(t('price', currentLang)),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _priceController,
                                hint: '0.00',
                                keyboardType: TextInputType.number,
                                prefix: 'P ',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(t('unit', currentLang)),
                              const SizedBox(height: 8),
                              _buildDropdownField(
                                value: _unit,
                                items: _units,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _unit = value);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle(t('quantity_available', currentLang)),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _quantityController,
                      hint: t('enter_quantity', currentLang),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isEditing
                              ? t('update_product', currentLang)
                              : t('add_product', currentLang),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(AppLanguage lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(t('product_image', lang)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < _existingImageUrls.length; i++)
                _buildExistingImageSlot(_existingImageUrls[i], i),
              for (int i = 0; i < _newImages.length; i++)
                _buildNewImageSlot(_newImages[i], i),
              if (_totalImageCount < 5) _buildAddSlot(lang),
            ],
          ),
        ),
        if (_totalImageCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '$_totalImageCount / 5 ${t('photos', lang).toLowerCase()}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
      ],
    );
  }

  Widget _buildExistingImageSlot(String url, int index) {
    return _imageSlot(
      child: Image.network(url, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.broken_image_outlined, color: Colors.grey[400])),
      onRemove: () => setState(() => _existingImageUrls.removeAt(index)),
    );
  }

  Widget _buildNewImageSlot(File file, int index) {
    return _imageSlot(
      child: Image.file(file, fit: BoxFit.cover),
      onRemove: () => setState(() => _newImages.removeAt(index)),
    );
  }

  Widget _imageSlot({required Widget child, required VoidCallback onRemove}) {
    return Container(
      width: 88,
      height: 88,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[100],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: child,
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSlot(AppLanguage lang) {
    return GestureDetector(
      onTap: _showImageSourcePicker,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
          color: Colors.grey[50],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, size: 28, color: Colors.grey[400]),
            const SizedBox(height: 4),
            Text(
              t('add_image_slot', lang),
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourcePicker() {
    final lang = ref.read(languageProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(t('take_photo', lang)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(t('choose_from_gallery', lang)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final lang = ref.read(languageProvider);
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (picked == null) return;
      final file = File(picked.path);
      final isValid = await ImageUtils.validateImage(file);
      if (!isValid && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('image_too_large', lang)),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() => _newImages.add(file));
    } catch (_) {
      // silently ignore picker cancellation
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? prefix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.green, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      final profile = ref.read(profileSetupProvider);

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final price = double.tryParse(_priceController.text);

      // Upload any new images
      final storageService = ref.read(firebaseStorageServiceProvider);
      final allImageUrls = List<String>.from(_existingImageUrls);
      for (int i = 0; i < _newImages.length; i++) {
        final compressed = await ImageUtils.compressProductImage(_newImages[i]);
        final url = await storageService.uploadMarketplaceImage(
          compressed,
          user.uid,
          listingId: widget.existingProduct?.id,
          index: allImageUrls.length + i,
        );
        allImageUrls.add(url);
      }

      final effectiveCategory = _category == 'Other'
          ? _otherCategoryController.text.trim().isNotEmpty
              ? _otherCategoryController.text.trim()
              : 'Other'
          : _category;

      final listing = MarketplaceListing(
        id: widget.existingProduct?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: ListingType.supplies,
        category: effectiveCategory,
        price: price,
        unit: _unit,
        quantity: _quantityController.text.trim(),
        sellerName: profile.businessName.isNotEmpty ? profile.businessName : 'Unknown',
        sellerId: user.uid,
        location: profile.location.isNotEmpty ? profile.location : 'Botswana',
        sellerEmail: user.email,
        inventoryId: widget.sourceInventory?.id,
        imagePath: allImageUrls.isNotEmpty ? allImageUrls.first : null,
        additionalImages: allImageUrls.length > 1 ? allImageUrls.sublist(1) : null,
      );

      String? error;
      if (_isEditing) {
        error = await ref
            .read(marketplaceNotifierProvider.notifier)
            .updateListing(listing);
      } else {
        error = await ref
            .read(marketplaceNotifierProvider.notifier)
            .addListing(listing);
      }

      if (mounted) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t(error, ref.read(languageProvider))), backgroundColor: Colors.red),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing
                  ? 'Product updated successfully'
                  : 'Product added successfully'),
              backgroundColor: AppColors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
