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

  final List<String> _cropTypes = [
    'maize',
    'sorghum',
    'beans',
    'cowpeas',
    'melons',
    'other',
  ];
  final List<String> _sizeUnits = ['hectares', 'acres'];
  final List<String> _yieldUnits = ['kg', 'bags', 'tons'];
  final List<String> _storageMethods = [
    'traditional_granary',
    'improved_storage',
    'bags_in_room',
    'open_air',
    'warehouse',
  ];

  String? _selectedCropType;
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
                    color: Colors.black.withOpacity(0.05),
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
      'beans': 90,
      'cowpeas': 75,
      'melons': 100,
      'other': 90,
    };

    if (_selectedCropType != null) {
      setState(() {
        _expectedHarvestDate = _plantingDate.add(
          Duration(days: daysToHarvest[_selectedCropType] ?? 90),
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
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedCropType,
          decoration: InputDecoration(
            hintText: t('select_crop_type', lang),
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
          items: _cropTypes.map((crop) {
            return DropdownMenuItem(value: crop, child: Text(t(crop, lang)));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCropType = value;
              _autoCalculateHarvestDate();
            });
          },
          validator: (value) => value == null ? t('required', lang) : null,
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
            const InfoTooltip(
              message: 'Give your field a name for easy identification',
            ),
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
          validator: (value) =>
              value?.isEmpty ?? true ? t('required', lang) : null,
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
              child: DropdownButtonFormField<String>(
                initialValue: _selectedSizeUnit,
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
                items: _sizeUnits.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(t(unit, lang)),
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
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
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
    _selectedCropType = crop.cropType;
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
    if (_formKey.currentState!.validate()) {
      final crop = CropModel(
        id: widget.existingCrop?.id,
        cropType: _selectedCropType!,
        fieldName: _fieldNameController.text,
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
