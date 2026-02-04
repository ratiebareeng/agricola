import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/widgets/info_tooltip.dart';
import 'package:agricola/core/widgets/step_indicator.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
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

  final Map<String, List<String>> _cropCategories = {
    'cereals_grains': ['maize', 'sorghum', 'wheat', 'rice', 'millet', 'barley'],
    'vegetables': [
      'tomatoes',
      'onions',
      'cabbage',
      'carrots',
      'peppers',
      'lettuce',
      'spinach',
    ],
    'fruits': [
      'watermelon',
      'oranges',
      'bananas',
      'grapes',
      'mangoes',
      'apples',
    ],
    'legumes_pulses': [
      'beans',
      'cowpeas',
      'peas',
      'lentils',
      'groundnuts',
      'soybeans',
    ],
    'root_tubers': ['potatoes', 'cassava', 'sweet_potatoes', 'yams'],
    'cash_crops': ['cotton', 'tobacco', 'coffee', 'tea', 'sugarcane'],
  };

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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(t(isEditing ? 'edit_crop' : 'add_crop', currentLang)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                  StepIndicator(currentStep: _currentStep, totalSteps: 3),
                  const SizedBox(height: 12),
                  Text(
                    _getStepTitle(currentLang),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildStepContent(currentLang),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFF2D6A4F)),
                        ),
                        child: Text(t('back', currentLang)),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentStep < 2 ? _nextStep : _saveCrop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D6A4F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentStep < 2
                            ? t('next', currentLang)
                            : t('save', currentLang),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

  void _autoCalculateHarvestDate() {
    final daysToHarvest = {
      'maize': 120,
      'sorghum': 110,
      'wheat': 120,
      'rice': 120,
      'millet': 90,
      'barley': 90,
      'tomatoes': 85,
      'onions': 120,
      'cabbage': 70,
      'carrots': 75,
      'peppers': 80,
      'lettuce': 50,
      'spinach': 40,
      'watermelon': 90,
      'oranges': 365,
      'bananas': 270,
      'grapes': 150,
      'mangoes': 365,
      'apples': 180,
      'beans': 90,
      'cowpeas': 75,
      'peas': 60,
      'lentils': 100,
      'groundnuts': 120,
      'soybeans': 120,
      'potatoes': 90,
      'cassava': 270,
      'sweet_potatoes': 120,
      'yams': 240,
      'cotton': 180,
      'tobacco': 90,
      'coffee': 365,
      'tea': 365,
      'sugarcane': 365,
      'other': 90,
    };

    if (_selectedCropTypes.isNotEmpty) {
      setState(() {
        final firstCrop = _selectedCropTypes.first;
        _expectedHarvestDate = _plantingDate.add(
          Duration(days: daysToHarvest[firstCrop] ?? 90),
        );
      });
    }
  }

  Widget _buildCropDetailsStep(AppLanguage lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              t('crop_type', lang),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(width: 8),
            const InfoTooltip(message: 'Select the crop you are planting'),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedCropTypes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              t('required', lang),
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
        // Container(
        //   padding: const EdgeInsets.all(12),
        //   decoration: BoxDecoration(
        //     color: Colors.blue.withAlpha(26),
        //     borderRadius: BorderRadius.circular(8),
        //     border: Border.all(color: Colors.blue.withAlpha(51)),
        //   ),
        //   child: Row(
        //     children: [
        //       const Icon(Icons.info_outline, color: Colors.blue, size: 20),
        //       const SizedBox(width: 8),
        //       Expanded(
        //         child: Text(
        //           t('select_multiple_crops_hint', lang),
        //           style: const TextStyle(fontSize: 12, color: Colors.blue),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        const SizedBox(height: 12),
        ..._cropCategories.entries.map((entry) {
          final categoryKey = entry.key;
          final crops = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 8),
                child: Text(
                  t(categoryKey, lang),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: crops.map((crop) {
                  final isSelected = _selectedCropTypes.contains(crop);
                  return FilterChip(
                    label: Text(t(crop, lang)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCropTypes = {crop};
                          _otherCropSelected = false;
                        } else {
                          _selectedCropTypes.remove(crop);
                        }
                        _autoCalculateHarvestDate();
                      });
                    },
                    selectedColor: const Color(0xFF2D6A4F).withAlpha(51),
                    checkmarkColor: const Color(0xFF2D6A4F),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF2D6A4F)
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFF2D6A4F)
                          : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }),
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
          selectedColor: const Color(0xFF2D6A4F).withAlpha(51),
          checkmarkColor: const Color(0xFF2D6A4F),
          backgroundColor: Colors.white,
          side: BorderSide(
            color: _otherCropSelected
                ? const Color(0xFF2D6A4F)
                : Colors.grey[300]!,
            width: _otherCropSelected ? 2 : 1,
          ),
          labelStyle: TextStyle(
            color: _otherCropSelected
                ? const Color(0xFF2D6A4F)
                : Colors.black87,
            fontWeight: _otherCropSelected
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
        if (_otherCropSelected)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextFormField(
              controller: _otherCropNameController,
              decoration: InputDecoration(
                labelText: t('specify_other_crop', lang),
                hintText: t('enter_crop_name', lang),
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
                  borderSide: const BorderSide(
                    color: Color(0xFF2D6A4F),
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (!_otherCropSelected) {
                  return null;
                }
                return value?.isEmpty ?? true ? t('required', lang) : null;
              },
              onEditingComplete: () {},
              onFieldSubmitted: (newValue) {
                if (newValue.isEmpty || _selectedCropTypes.contains(newValue)) {
                  return;
                }

                setState(() {
                  _selectedCropTypes = {newValue};
                  _autoCalculateHarvestDate();
                });
              },
            ),
          ),

        if (_selectedCropTypes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2D6A4F).withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF2D6A4F),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_selectedCropTypes.length} ${t(_selectedCropTypes.length == 1 ? "crop_selected" : "crops_selected", lang)}',
                          style: const TextStyle(
                            color: Color(0xFF2D6A4F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Only show chips for custom "other" crops
                  if (_selectedCropTypes.any(
                    (crop) =>
                        !_cropCategories.values.any(
                          (list) => list.contains(crop),
                        ) &&
                        crop != 'other',
                  )) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedCropTypes
                          .where(
                            (cropType) =>
                                !_cropCategories.values.any(
                                  (list) => list.contains(cropType),
                                ) &&
                                cropType != 'other',
                          )
                          .map((cropType) {
                            return Chip(
                              label: Text(cropType),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                setState(() {
                                  _selectedCropTypes.remove(cropType);
                                  _autoCalculateHarvestDate();
                                });
                              },
                              backgroundColor: const Color(
                                0xFF2D6A4F,
                              ).withAlpha(51),
                              labelStyle: const TextStyle(
                                color: Color(0xFF2D6A4F),
                                fontWeight: FontWeight.w600,
                              ),
                              deleteIconColor: const Color(0xFF2D6A4F),
                            );
                          })
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              t('field_name', lang),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(width: 8),
            InfoTooltip(message: 'Optional - will auto-generate name if empty'),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _fieldNameController,
          decoration: InputDecoration(
            hintText: t('enter_field_name', lang),
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
              borderSide: const BorderSide(color: Color(0xFF2D6A4F), width: 2),
            ),
          ),
          validator: (value) {
            // Field name is now optional for both single and multiple crops
            // as we auto-generate names when empty
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFieldInfoStep(AppLanguage lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              t('field_size', lang),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(width: 8),
            const InfoTooltip(message: 'Enter the size of your field'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _fieldSizeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0.0',
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
                    borderSide: const BorderSide(
                      color: Color(0xFF2D6A4F),
                      width: 2,
                    ),
                  ),
                ),
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
              child: DropdownButtonFormField<String>(
                initialValue: _selectedSizeUnit,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
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
                    borderSide: const BorderSide(
                      color: Color(0xFF2D6A4F),
                      width: 2,
                    ),
                  ),
                ),
                items: _sizeUnits.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(
                      t(unit, lang),
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedSizeUnit = value!);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          t('planting_date', lang),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _plantingDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _plantingDate = date;
                _autoCalculateHarvestDate();
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF2D6A4F)),
                const SizedBox(width: 12),
                Text(
                  '${_plantingDate.day}/${_plantingDate.month}/${_plantingDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              t('expected_harvest_date', lang),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(width: 8),
            const InfoTooltip(message: 'Auto-calculated based on crop type'),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _expectedHarvestDate ?? DateTime.now(),
              firstDate: _plantingDate,
              lastDate: DateTime(2030),
            );
            if (date != null) {
              setState(() => _expectedHarvestDate = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF2D6A4F)),
                const SizedBox(width: 12),
                Text(
                  _expectedHarvestDate != null
                      ? '${_expectedHarvestDate!.day}/${_expectedHarvestDate!.month}/${_expectedHarvestDate!.year}'
                      : t('auto_calculate_harvest', lang),
                  style: TextStyle(
                    fontSize: 16,
                    color: _expectedHarvestDate != null
                        ? Colors.black87
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              t('estimated_yield', lang),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(width: 8),
            const InfoTooltip(message: 'Estimate your expected yield'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _estimatedYieldController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0.0',
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
                    borderSide: const BorderSide(
                      color: Color(0xFF2D6A4F),
                      width: 2,
                    ),
                  ),
                ),
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
              child: DropdownButtonFormField<String>(
                initialValue: _selectedYieldUnit,
                decoration: InputDecoration(
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
                    borderSide: const BorderSide(
                      color: Color(0xFF2D6A4F),
                      width: 2,
                    ),
                  ),
                ),
                items: _yieldUnits.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(t(unit, lang)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedYieldUnit = value!);
                },
              ),
            ),
          ],
        ),
        if (_estimatedYieldController.text.isNotEmpty &&
            double.tryParse(_estimatedYieldController.text) != null) ...[
          const SizedBox(height: 16),
          Container(
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
                    const Icon(
                      Icons.warning_amber,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t('post_harvest_loss', lang),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t('estimated_loss_15', lang),
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    Text(
                      '${(double.parse(_estimatedYieldController.text) * 0.15).toStringAsFixed(1)} ${t(_selectedYieldUnit, lang)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t('expected_after_loss', lang),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(double.parse(_estimatedYieldController.text) * 0.85).toStringAsFixed(1)} ${t(_selectedYieldUnit, lang)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D6A4F),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              t('storage_method', lang),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(width: 8),
            const InfoTooltip(message: 'How will you store your harvest?'),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedStorageMethod,
          decoration: InputDecoration(
            hintText: 'Select storage method',
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
              borderSide: const BorderSide(color: Color(0xFF2D6A4F), width: 2),
            ),
          ),
          items: _storageMethods.map((method) {
            return DropdownMenuItem(
              value: method,
              child: Text(t(method, lang)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedStorageMethod = value);
          },
          validator: (value) => value == null ? t('required', lang) : null,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              t('notes', lang),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${t('optional', lang)})',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Add any additional information...',
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
              borderSide: const BorderSide(color: Color(0xFF2D6A4F), width: 2),
            ),
          ),
        ),
      ],
    );
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
          content: Text(
            t('select_at_least_one_crop', ref.watch(languageProvider)),
          ),
          backgroundColor: Colors.red,
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

      final cropType = _selectedCropTypes.first;
      final cropName =
          cropType == 'other' && _otherCropNameController.text.isNotEmpty
          ? _otherCropNameController.text
          : cropType;

      final displayName =
          cropType == 'other' && _otherCropNameController.text.isNotEmpty
          ? _otherCropNameController.text
          : t(cropType, lang);

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
