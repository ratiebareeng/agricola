import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:agricola/core/widgets/app_date_field.dart';
import 'package:agricola/core/widgets/app_network_image.dart';
import 'package:agricola/core/widgets/app_dropdown_field.dart';
import 'package:agricola/core/widgets/app_form_layout.dart';
import 'package:agricola/core/widgets/app_form_section.dart';
import 'package:agricola/core/widgets/app_text_field.dart';
import 'package:agricola/core/utils/image_utils.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/crops/models/crop_catalog_entry.dart';
import 'package:agricola/features/crops/providers/crop_catalog_provider.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:agricola/features/profile/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

const _maxImages = 5;

class AddEditInventoryScreen extends ConsumerStatefulWidget {
  final InventoryModel? existingItem;

  const AddEditInventoryScreen({super.key, this.existingItem});

  @override
  ConsumerState<AddEditInventoryScreen> createState() =>
      _AddEditInventoryScreenState();
}

class _AddEditInventoryScreenState
    extends ConsumerState<AddEditInventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  late String _cropType;
  late double _quantity;
  late String _unit;
  late DateTime _storageDate;
  late String _storageLocation;
  late String _condition;
  String? _notes;
  bool _isLoading = false;

  // Existing URLs from the server (kept when editing)
  late List<String> _existingImageUrls;
  // Newly picked local files (not yet uploaded)
  final List<File> _newImages = [];

  int get _totalImageCount => _existingImageUrls.length + _newImages.length;

  final List<String> _units = [
    'kg',
    'g',
    'tons',
    'bags',
    'sacks',
    'crates',
    'litres',
    'pieces',
    'bundles',
    'heads',
    'dozen',
    'bales',
    'trays',
  ];

  final List<String> _conditions = [
    'excellent',
    'good',
    'fair',
    'needs_attention',
    'critical',
  ];

  final List<String> _storageLocations = [
    'Traditional Granary',
    'Home Storage',
    'Cold Storage',
    'Silo',
    'Sold Fresh',
  ];

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final item = widget.existingItem!;
      _cropType = item.cropType;
      _quantity = item.quantity;
      _unit = item.unit;
      _storageDate = item.storageDate;
      _storageLocation = item.storageLocation;
      _condition = item.condition;
      _notes = item.notes;
      _existingImageUrls = List<String>.from(item.imageUrls);
    } else {
      _cropType = 'maize_corn';
      _quantity = 0;
      _unit = _units.first;
      _storageDate = DateTime.now();
      _storageLocation = _storageLocations.first;
      _condition = 'good';
      _notes = null;
      _existingImageUrls = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final catalogAsync = ref.watch(cropCatalogProvider);
    final cropKeys = catalogAsync.valueOrNull?.map((e) => e.key).toList() ?? [];
    final catalogEntries = catalogAsync.valueOrNull ?? <CropCatalogEntry>[];

    String cropLabel(String key) {
      final entry = catalogEntries.cast<CropCatalogEntry?>().firstWhere(
        (e) => e?.key == key,
        orElse: () => null,
      );
      return entry?.displayName(currentLang) ?? t(key, currentLang);
    }

    return AppFormLayout(
      title: _isEditing
          ? t('edit_inventory', currentLang)
          : t('add_inventory', currentLang),
      submitLabel: _isEditing
          ? t('update_inventory', currentLang)
          : t('save_inventory', currentLang),
      isLoading: _isLoading,
      onSubmit: _isLoading ? null : _saveInventory,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFormSection(
              title: t('photos', currentLang),
              description: t('photos_optional_hint', currentLang),
              child: _buildImagePicker(currentLang),
            ),
            const SizedBox(height: 24),
            AppFormSection(
              title: t('crop_type', currentLang),
              child: AppDropdownField<String>(
                value: cropKeys.contains(_cropType)
                    ? _cropType
                    : (cropKeys.isNotEmpty ? cropKeys.first : _cropType),
                items: cropKeys.isEmpty ? [_cropType] : cropKeys,
                itemLabelBuilder: cropLabel,
                onChanged: (value) {
                  if (value != null) setState(() => _cropType = value);
                },
              ),
            ),
            const SizedBox(height: 24),
            AppFormSection(
              title: t('quantity', currentLang),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppTextField(
                      label: '',
                      initialValue: _isEditing ? AgriKit.formatQuantity(_quantity) : '',
                      keyboardType: TextInputType.number,
                      hint: t('enter_quantity', currentLang),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return t('quantity_required', currentLang);
                        }
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed <= 0) {
                          return t('quantity_invalid', currentLang);
                        }
                        return null;
                      },
                      onSaved: (value) => _quantity = double.parse(value!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 22),
                      child: AppDropdownField<String>(
                        value: _unit,
                        items: _units,
                        itemLabelBuilder: (item) => item,
                        onChanged: (value) {
                          if (value != null) setState(() => _unit = value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppFormSection(
              title: t('storage_date', currentLang),
              child: AppDateField(
                value: _storageDate,
                onChanged: (picked) => setState(() => _storageDate = picked),
                lastDate: DateTime.now(),
              ),
            ),
            const SizedBox(height: 24),
            AppFormSection(
              title: t('storage_location', currentLang),
              child: AppDropdownField<String>(
                value: _storageLocation,
                items: _storageLocations,
                itemLabelBuilder: (item) => item,
                onChanged: (value) {
                  if (value != null) setState(() => _storageLocation = value);
                },
              ),
            ),
            const SizedBox(height: 24),
            AppFormSection(
              title: t('condition', currentLang),
              child: _buildConditionSelector(currentLang),
            ),
            const SizedBox(height: 24),
            AppFormSection(
              title: t('notes', currentLang),
              description: t('optional', currentLang),
              child: AppTextField(
                label: '',
                initialValue: _notes,
                maxLines: 3,
                hint: t('add_notes', currentLang),
                onSaved: (value) =>
                    _notes = value?.isEmpty == true ? null : value,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(AppLanguage lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Existing uploaded images
              for (int i = 0; i < _existingImageUrls.length; i++)
                _buildExistingImageSlot(_existingImageUrls[i], i),
              // New local images not yet uploaded
              for (int i = 0; i < _newImages.length; i++)
                _buildNewImageSlot(_newImages[i], i),
              // Add button (only when under the limit)
              if (_totalImageCount < _maxImages) _buildAddSlot(lang),
            ],
          ),
        ),
        if (_totalImageCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '$_totalImageCount / $_maxImages ${t('photos', lang).toLowerCase()}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
      ],
    );
  }

  Widget _buildExistingImageSlot(String url, int index) {
    return _imageSlot(
      child: AppNetworkImage(
        url: url,
        errorWidget: Icon(Icons.broken_image_outlined, color: Colors.grey[400]),
      ),
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
      onTap: () => _showImageSourcePicker(lang),
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

  void _showImageSourcePicker(AppLanguage lang) {
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
                _pickSingleImage(ImageSource.camera, lang);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(t('choose_from_gallery', lang)),
              onTap: () {
                Navigator.pop(context);
                _pickMultipleImages(lang);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSingleImage(ImageSource source, AppLanguage lang) async {
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
      if (mounted) setState(() => _newImages.add(file));
    } catch (_) {
      // silently ignore picker cancellation
    }
  }

  Future<void> _pickMultipleImages(AppLanguage lang) async {
    try {
      final remaining = _maxImages - _totalImageCount;
      if (remaining <= 0) return;
      final picked = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (picked.isEmpty) return;
      final limited = picked.take(remaining).toList();
      for (final xFile in limited) {
        final file = File(xFile.path);
        final isValid = await ImageUtils.validateImage(file);
        if (!isValid) continue;
        if (mounted) setState(() => _newImages.add(file));
      }
    } catch (_) {
      // silently ignore picker cancellation
    }
  }

  void _saveInventory() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState?.save();
    _uploadAndSave();
  }

  Future<void> _uploadAndSave() async {
    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      final storageService = ref.read(firebaseStorageServiceProvider);
      final uploadedUrls = List<String>.from(_existingImageUrls);

      for (int i = 0; i < _newImages.length; i++) {
        final compressed = await ImageUtils.compressProductImage(_newImages[i]);
        final url = await storageService.uploadInventoryImage(
          compressed,
          user?.uid ?? 'unknown',
          index: uploadedUrls.length + i,
        );
        uploadedUrls.add(url);
      }

      final item = InventoryModel(
        id: widget.existingItem?.id,
        cropType: _cropType,
        quantity: _quantity,
        unit: _unit,
        storageDate: _storageDate,
        storageLocation: _storageLocation,
        condition: _condition,
        notes: _notes,
        imageUrls: uploadedUrls,
        createdAt: widget.existingItem?.createdAt,
        updatedAt: DateTime.now(),
      );

      if (mounted) Navigator.pop(context, item);
    } catch (e, st) {
      debugPrint('Inventory upload error: $e\n$st');
      if (mounted) {
        setState(() => _isLoading = false);
        final lang = ref.read(languageProvider);
        final message = kDebugMode
            ? '${t('error_upload_failed', lang)}: $e'
            : t('error_upload_failed', lang);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildConditionSelector(AppLanguage lang) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _conditions.map((condition) {
        final isSelected = _condition == condition;
        final color = _getConditionColor(condition);
        return GestureDetector(
          onTap: () => setState(() => _condition = condition),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color.withAlpha(30) : AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : AppColors.lightGray,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getConditionIcon(condition),
                  size: 16,
                  color: isSelected ? color : AppColors.mediumGray,
                ),
                const SizedBox(width: 6),
                Text(
                  t(condition, lang),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? color : AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'excellent':
      case 'good':
        return AppColors.green;
      case 'fair':
      case 'needs_attention':
        return AppColors.warmYellow;
      case 'critical':
        return AppColors.alertRed;
      default:
        return AppColors.mediumGray;
    }
  }

  IconData _getConditionIcon(String condition) {
    switch (condition) {
      case 'excellent':
        return Icons.check_circle;
      case 'good':
        return Icons.thumb_up;
      case 'fair':
        return Icons.info;
      case 'needs_attention':
        return Icons.warning_amber;
      case 'critical':
        return Icons.error;
      default:
        return Icons.help;
    }
  }
}
