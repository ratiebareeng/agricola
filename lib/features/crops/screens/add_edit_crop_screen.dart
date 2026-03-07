import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/app_buttons.dart';
import 'package:agricola/core/widgets/app_date_field.dart';
import 'package:agricola/core/widgets/app_dropdown_field.dart';
import 'package:agricola/core/widgets/app_form_layout.dart';
import 'package:agricola/core/widgets/app_form_section.dart';
import 'package:agricola/core/widgets/app_text_field.dart';
import 'package:agricola/core/widgets/step_indicator.dart';
import 'package:agricola/features/crops/models/crop_catalog_entry.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:agricola/features/crops/providers/crop_catalog_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddEditCropScreen extends ConsumerStatefulWidget {
  final CropModel? existingCrop;

  const AddEditCropScreen({super.key, this.existingCrop});

  @override
  ConsumerState<AddEditCropScreen> createState() => _AddEditCropScreenState();
}

class _AddEditCropScreenState extends ConsumerState<AddEditCropScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  final List<String> _sizeUnits = ['hectares', 'Metres (m\u00B2)'];
  final List<String> _yieldUnits = ['kg', 'bags', 'tons'];
  final List<String> _storageMethods = [
    'traditional_granary',
    'improved_storage',
    'bags_in_room',
    'open_air',
    'warehouse',
  ];
  Set<String> _selectedCropTypes = {};

  final TextEditingController _fieldNameController = TextEditingController();
  final TextEditingController _fieldSizeController = TextEditingController();
  String _selectedSizeUnit = 'hectares';
  DateTime _plantingDate = DateTime.now();
  DateTime? _expectedHarvestDate;
  final TextEditingController _estimatedYieldController =
      TextEditingController();
  String _selectedYieldUnit = 'kg';
  String? _selectedStorageMethod;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _otherCropNameController =
      TextEditingController();
  bool _otherCropSelected = false;

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final isEditing = widget.existingCrop != null;

    return AppFormLayout(
      title: t(isEditing ? 'edit_crop' : 'add_crop', currentLang),
      bottomWidget: _buildBottomNavigationBar(currentLang),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  StepIndicator(currentStep: _currentStep, totalSteps: 3),
                  const SizedBox(height: 16),
                  Text(
                    _getStepTitle(currentLang),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildStepContent(currentLang),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fieldNameController.dispose();
    _fieldSizeController.dispose();
    _estimatedYieldController.dispose();
    _notesController.dispose();
    _otherCropNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingCrop != null) {
      _loadExistingCrop();
    }
  }

  Widget _buildBottomNavigationBar(AppLanguage lang) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                child: AppSecondaryButton(
                  label: t('back', lang),
                  onTap: _previousStep,
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: AppPrimaryButton(
                label: _currentStep < 2 ? t('next', lang) : t('save', lang),
                onTap: _currentStep < 2 ? _nextStep : _saveCrop,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropDetailsStep(AppLanguage lang) {
    final catalogByCategory = ref.watch(cropCatalogByCategoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFormSection(
          title: t('crop_type', lang),
          tooltip: 'Select the crop you are planting',
          isRequired: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              catalogByCategory.when(
                data: (categoryMap) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categoryMap.entries.map((entry) {
                    final categoryKey = entry.key;
                    final crops = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 8),
                          child: Text(
                            t(categoryKey, lang),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mediumGray,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: crops.map((catalogEntry) {
                            final isSelected = _selectedCropTypes.contains(
                              catalogEntry.key,
                            );
                            return FilterChip(
                              label: Text(catalogEntry.displayName(lang)),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedCropTypes = {catalogEntry.key};
                                    _otherCropSelected = false;
                                  } else {
                                    _selectedCropTypes.remove(catalogEntry.key);
                                  }
                                  _autoCalculateHarvestDate();
                                });
                              },
                              selectedColor: AppColors.green.withAlpha(50),
                              checkmarkColor: AppColors.green,
                              backgroundColor: AppColors.white,
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.green
                                    : AppColors.lightGray,
                                width: isSelected ? 2 : 1,
                              ),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppColors.green
                                    : AppColors.darkGray,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
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
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Failed to load crop catalog',
                    style: TextStyle(color: AppColors.alertRed),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilterChip(
                label: Text(t('other', lang)),
                selected: _otherCropSelected,
                onSelected: (selected) {
                  setState(() {
                    _otherCropSelected = selected;
                    if (selected) {
                      _selectedCropTypes.clear();
                    } else {
                      _otherCropNameController.clear();
                    }
                  });
                },
                selectedColor: AppColors.green.withAlpha(50),
                checkmarkColor: AppColors.green,
                backgroundColor: AppColors.white,
                side: BorderSide(
                  color: _otherCropSelected
                      ? AppColors.green
                      : AppColors.lightGray,
                  width: _otherCropSelected ? 2 : 1,
                ),
                labelStyle: TextStyle(
                  color: _otherCropSelected
                      ? AppColors.green
                      : AppColors.darkGray,
                  fontWeight: _otherCropSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (_otherCropSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: AppTextField(
                    label: t('specify_other_crop', lang),
                    hint: t('enter_crop_name', lang),
                    controller: _otherCropNameController,
                    validator: (value) {
                      if (!_otherCropSelected) return null;
                      return value?.isEmpty ?? true ? t('required', lang) : null;
                    },
                    onChanged: (newValue) {
                      if (newValue.isNotEmpty) {
                        setState(() {
                          _selectedCropTypes = {newValue};
                          _autoCalculateHarvestDate();
                        });
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AppFormSection(
          title: t('field_name', lang),
          tooltip: 'Optional - will auto-generate name if empty',
          child: AppTextField(
            label: '',
            controller: _fieldNameController,
            hint: t('enter_field_name', lang),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldInfoStep(AppLanguage lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFormSection(
          title: t('field_size', lang),
          isRequired: true,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: AppTextField(
                  label: '',
                  controller: _fieldSizeController,
                  keyboardType: TextInputType.number,
                  hint: '0.0',
                  validator: (value) {
                    if (value?.isEmpty ?? true) return t('required', lang);
                    if (double.tryParse(value!) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 22),
                  child: AppDropdownField<String>(
                    value: _selectedSizeUnit,
                    items: _sizeUnits,
                    itemLabelBuilder: (unit) => t(unit, lang),
                    onChanged: (value) {
                      setState(() => _selectedSizeUnit = value!);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AppFormSection(
          title: t('planting_date', lang),
          isRequired: true,
          child: AppDateField(
            value: _plantingDate,
            onChanged: (date) {
              setState(() {
                _plantingDate = date;
                _autoCalculateHarvestDate();
              });
            },
            lastDate: DateTime.now(),
          ),
        ),
        const SizedBox(height: 24),
        AppFormSection(
          title: t('expected_harvest_date', lang),
          tooltip: 'Auto-calculated based on crop type',
          child: AppDateField(
            value: _expectedHarvestDate ?? DateTime.now(),
            onChanged: (date) => setState(() => _expectedHarvestDate = date),
            firstDate: _plantingDate,
            hint: t('auto_calculate_harvest', lang),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(AppLanguage lang) {
    switch (_currentStep) {
      case 0:
        return _buildCropDetailsStep(lang);
      case 1:
        return _buildFieldInfoStep(lang);
      case 2:
        return _buildYieldStorageStep(lang);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildYieldStorageStep(AppLanguage lang) {
    final yieldText = _estimatedYieldController.text;
    final hasValidYield = yieldText.isNotEmpty && double.tryParse(yieldText) != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFormSection(
          title: t('estimated_yield', lang),
          tooltip: 'Estimate your expected yield',
          isRequired: true,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: AppTextField(
                  label: '',
                  controller: _estimatedYieldController,
                  keyboardType: TextInputType.number,
                  hint: '0.0',
                  validator: (value) {
                    if (value?.isEmpty ?? true) return t('required', lang);
                    if (double.tryParse(value!) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 22),
                  child: AppDropdownField<String>(
                    value: _selectedYieldUnit,
                    items: _yieldUnits,
                    itemLabelBuilder: (unit) => t(unit, lang),
                    onChanged: (value) {
                      setState(() => _selectedYieldUnit = value!);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasValidYield) ...[
          const SizedBox(height: 16),
          _buildLossCalculationCard(lang, double.parse(yieldText)),
        ],
        const SizedBox(height: 24),
        AppFormSection(
          title: t('storage_method', lang),
          tooltip: 'How will you store your harvest?',
          isRequired: true,
          child: AppDropdownField<String>(
            value: _selectedStorageMethod,
            items: _storageMethods,
            itemLabelBuilder: (method) => t(method, lang),
            hint: 'Select storage method',
            onChanged: (value) => setState(() => _selectedStorageMethod = value),
            validator: (value) => value == null ? t('required', lang) : null,
          ),
        ),
        const SizedBox(height: 24),
        AppFormSection(
          title: t('notes', lang),
          description: t('optional', lang),
          child: AppTextField(
            label: '',
            controller: _notesController,
            maxLines: 4,
            hint: 'Add any additional information...',
          ),
        ),
      ],
    );
  }

  Widget _buildLossCalculationCard(AppLanguage lang, double yieldValue) {
    final loss = yieldValue * 0.15;
    final afterLoss = yieldValue * 0.85;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withAlpha(51)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                t('post_harvest_loss', lang),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLossRow(t('estimated_loss_15', lang), '${loss.toStringAsFixed(1)} ${t(_selectedYieldUnit, lang)}', Colors.orange),
          const Divider(height: 20),
          _buildLossRow(t('expected_after_loss', lang), '${afterLoss.toStringAsFixed(1)} ${t(_selectedYieldUnit, lang)}', AppColors.green, isBold: true),
        ],
      ),
    );
  }

  Widget _buildLossRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.darkGray : AppColors.mediumGray,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _autoCalculateHarvestDate() {
    final harvestDaysMap = ref.read(harvestDaysProvider).valueOrNull ?? {};

    if (_selectedCropTypes.isNotEmpty) {
      setState(() {
        final firstCrop = _selectedCropTypes.first;
        _expectedHarvestDate = _plantingDate.add(
          Duration(days: harvestDaysMap[firstCrop] ?? 90),
        );
      });
    }
  }

  String _getStepTitle(AppLanguage lang) {
    switch (_currentStep) {
      case 0:
        return t('crop_details', lang);
      case 1:
        return t('field_info', lang);
      case 2:
        return t('yield_storage', lang);
      default:
        return '';
    }
  }

  void _loadExistingCrop() {
    final crop = widget.existingCrop!;
    _selectedCropTypes = {crop.cropType};
    _fieldNameController.text = crop.fieldName;
    _fieldSizeController.text = crop.fieldSize.toString();
    _selectedSizeUnit = crop.fieldSizeUnit;
    _plantingDate = crop.plantingDate;
    _expectedHarvestDate = crop.expectedHarvestDate;
    _estimatedYieldController.text = crop.estimatedYield.toString();
    _selectedYieldUnit = crop.yieldUnit;
    _selectedStorageMethod = crop.storageMethod;
    _notesController.text = crop.notes ?? '';
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedCropTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('select_at_least_one_crop', ref.watch(languageProvider))),
          backgroundColor: AppColors.alertRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _saveCrop() {
    if (_formKey.currentState!.validate() && _selectedCropTypes.isNotEmpty) {
      final lang = ref.watch(languageProvider);
      final catalog = ref.read(cropCatalogProvider).valueOrNull ?? [];

      final cropType = _selectedCropTypes.first;
      final cropName =
          cropType == 'other' && _otherCropNameController.text.isNotEmpty
          ? _otherCropNameController.text
          : cropType;

      final catalogEntry = catalog.cast<CropCatalogEntry?>().firstWhere(
        (e) => e?.key == cropType,
        orElse: () => null,
      );
      final displayName = catalogEntry != null
          ? catalogEntry.displayName(lang)
          : (cropType == 'other' && _otherCropNameController.text.isNotEmpty
                ? _otherCropNameController.text
                : t(cropType, lang));

      final crop = CropModel(
        id: widget.existingCrop?.id,
        cropType: cropName,
        fieldName: _fieldNameController.text.isEmpty
            ? '$displayName Field'
            : _fieldNameController.text,
        fieldSize: double.parse(_fieldSizeController.text),
        fieldSizeUnit: _selectedSizeUnit,
        plantingDate: _plantingDate,
        expectedHarvestDate: _expectedHarvestDate ?? _plantingDate,
        estimatedYield: double.parse(_estimatedYieldController.text),
        yieldUnit: _selectedYieldUnit,
        storageMethod: _selectedStorageMethod!,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      Navigator.pop(context, crop);
    }
  }
}
