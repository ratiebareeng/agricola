import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/marketplace/models/marketplace_listing.dart';
import 'package:agricola/features/marketplace/providers/marketplace_provider.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  final MarketplaceListing? existingProduct;

  const AddProductScreen({super.key, this.existingProduct});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;

  String _category = 'Seeds';
  String _unit = 'kg';

  final List<String> _categories = [
    'Seeds',
    'Fertilizers',
    'Pesticides',
    'Tools & Equipment',
    'Irrigation',
    'Animal Feed',
    'Packaging',
    'Other',
  ];

  final List<String> _units = ['kg', 'bags', 'litres', 'pieces', 'boxes'];

  bool get _isEditing => widget.existingProduct != null;

  @override
  void initState() {
    super.initState();
    final product = widget.existingProduct;
    _titleController = TextEditingController(text: product?.title ?? '');
    _descriptionController =
        TextEditingController(text: product?.description ?? '');
    _priceController =
        TextEditingController(text: product?.price?.toString() ?? '');
    _quantityController =
        TextEditingController(text: product?.quantity ?? '');

    if (product != null) {
      _category = product.category;
      _unit = product.unit ?? 'kg';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
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

      final listing = MarketplaceListing(
        id: widget.existingProduct?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: ListingType.supplies,
        category: _category,
        price: price,
        unit: _unit,
        quantity: _quantityController.text.trim(),
        sellerName: profile.businessName.isNotEmpty ? profile.businessName : 'Unknown',
        sellerId: user.uid,
        location: profile.location.isNotEmpty ? profile.location : 'Botswana',
        sellerEmail: user.email,
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
            SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
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
