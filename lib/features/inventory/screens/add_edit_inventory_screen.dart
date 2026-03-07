import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/app_date_field.dart';
import 'package:agricola/core/widgets/app_dropdown_field.dart';
import 'package:agricola/core/widgets/app_form_layout.dart';
import 'package:agricola/core/widgets/app_form_section.dart';
import 'package:agricola/core/widgets/app_text_field.dart';
import 'package:agricola/features/crops/models/crop_catalog_entry.dart';
import 'package:agricola/features/crops/providers/crop_catalog_provider.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  late String _cropType;
  late double _quantity;
  late String _unit;
  late DateTime _storageDate;
  late String _storageLocation;
  late String _condition;
  String? _notes;

  final List<String> _units = ['kg', 'bags', 'tons'];

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
  ];

  bool get _isEditing => widget.existingItem != null;

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final catalogAsync = ref.watch(cropCatalogProvider);
    final cropKeys = catalogAsync.valueOrNull
            ?.map((e) => e.key)
            .toList() ??
        [];
    
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
      onSubmit: _saveInventory,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFormSection(
              title: t('crop_type', currentLang),
              child: AppDropdownField<String>(
                value: cropKeys.contains(_cropType) ? _cropType : (cropKeys.isNotEmpty ? cropKeys.first : _cropType),
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
                      label: '', // Label is handled by AppFormSection
                      initialValue: _isEditing ? _quantity.toString() : '',
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
                      padding: const EdgeInsets.only(top: 22), // Align with text field
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
                onSaved: (value) => _notes = value?.isEmpty == true ? null : value,
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
    if (_isEditing) {
      final item = widget.existingItem!;
      _cropType = item.cropType;
      _quantity = item.quantity;
      _unit = item.unit;
      _storageDate = item.storageDate;
      _storageLocation = item.storageLocation;
      _condition = item.condition;
      _notes = item.notes;
    } else {
      _cropType = 'maize_corn';
      _quantity = 0;
      _unit = _units.first;
      _storageDate = DateTime.now();
      _storageLocation = _storageLocations.first;
      _condition = 'good';
      _notes = null;
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
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
        return Colors.green[700]!;
      case 'good':
        return AppColors.green;
      case 'fair':
        return Colors.orange[600]!;
      case 'needs_attention':
        return Colors.orange[800]!;
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

  void _saveInventory() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final item = InventoryModel(
        id: widget.existingItem?.id,
        cropType: _cropType,
        quantity: _quantity,
        unit: _unit,
        storageDate: _storageDate,
        storageLocation: _storageLocation,
        condition: _condition,
        notes: _notes,
        createdAt: widget.existingItem?.createdAt,
        updatedAt: DateTime.now(),
      );

      Navigator.pop(context, item);
    }
  }
}
