import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:agricola/features/crops/models/harvest_model.dart';
import 'package:agricola/features/crops/widgets/quality_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecordHarvestScreen extends ConsumerStatefulWidget {
  final CropModel crop;

  const RecordHarvestScreen({super.key, required this.crop});

  @override
  ConsumerState<RecordHarvestScreen> createState() =>
      _RecordHarvestScreenState();
}

class _RecordHarvestScreenState extends ConsumerState<RecordHarvestScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime _harvestDate = DateTime.now();
  final TextEditingController _actualYieldController = TextEditingController();
  String _selectedYieldUnit = 'kg';
  String? _selectedQuality;
  final TextEditingController _lossAmountController = TextEditingController();
  String? _selectedLossReason;
  final TextEditingController _customLossReasonController =
      TextEditingController();
  final TextEditingController _storageLocationController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> _yieldUnits = ['kg', 'bags', 'tons'];
  final List<String> _lossReasons = [
    'pest_damage',
    'spoilage',
    'weather_damage',
    'handling_damage',
    'other_loss',
  ];

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final difference = _calculateDifference();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(t('record_harvest', currentLang)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.grass, color: Colors.green),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.crop.fieldName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  t(widget.crop.cropType, currentLang),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t('harvest_date', currentLang),
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
                          initialDate: _harvestDate,
                          firstDate: widget.crop.plantingDate,
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _harvestDate = date);
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
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF2D6A4F),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${_harvestDate.day}/${_harvestDate.month}/${_harvestDate.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t('actual_yield', currentLang),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _actualYieldController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '0.0',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
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
                              if (value?.isEmpty ?? true) {
                                return t('required', currentLang);
                              }
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
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedYieldUnit,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
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
                                child: Text(t(unit, currentLang)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedYieldUnit = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                    if (difference != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: difference >= 0
                              ? Colors.green.withAlpha(10)
                              : Colors.orange.withAlpha(10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: difference >= 0
                                ? Colors.green.withAlpha(30)
                                : Colors.orange.withAlpha(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  t('expected', currentLang),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${widget.crop.estimatedYield} ${t(_selectedYieldUnit, currentLang)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  t('actual', currentLang),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${_actualYieldController.text} ${t(_selectedYieldUnit, currentLang)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  t('difference', currentLang),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${difference >= 0 ? '+' : ''}${difference.toStringAsFixed(1)} ${t(_selectedYieldUnit, currentLang)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: difference >= 0
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      t('quality_assessment', currentLang),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    QualitySelector(
                      selectedQuality: _selectedQuality,
                      onQualitySelected: (quality) {
                        setState(() => _selectedQuality = quality);
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t('immediate_losses', currentLang),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '(${t('optional', currentLang)})',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _lossAmountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: t('enter_loss_amount', currentLang),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2D6A4F),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              t(_selectedYieldUnit, currentLang),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedLossReason,
                      decoration: InputDecoration(
                        hintText: t('loss_reason', currentLang),
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
                      items: _lossReasons.map((reason) {
                        return DropdownMenuItem(
                          value: reason,
                          child: Text(t(reason, currentLang)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedLossReason = value);
                      },
                    ),
                    if (_selectedLossReason == 'other_loss') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _customLossReasonController,
                        decoration: InputDecoration(
                          hintText: t('enter_loss_reason', currentLang),
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
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      t('storage_location', currentLang),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _storageLocationController,
                      decoration: InputDecoration(
                        hintText: 'E.g., Warehouse A, Home storage',
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
                      validator: (value) => value?.isEmpty ?? true
                          ? t('required', currentLang)
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t('notes', currentLang),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '(${t('optional', currentLang)})',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Add any additional notes...',
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
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
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
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFF2D6A4F)),
                      ),
                      child: Text(t('cancel', currentLang)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _saveHarvest,
                      icon: const Icon(Icons.inventory_2),
                      label: Text(t('save_to_inventory', currentLang)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D6A4F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
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
    _actualYieldController.dispose();
    _lossAmountController.dispose();
    _customLossReasonController.dispose();
    _storageLocationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedYieldUnit = widget.crop.yieldUnit;
    _storageLocationController.text = widget.crop.storageMethod;
  }

  double? _calculateDifference() {
    if (_actualYieldController.text.isNotEmpty) {
      final actual = double.parse(_actualYieldController.text);
      return actual - widget.crop.estimatedYield;
    }
    return null;
  }

  void _saveHarvest() {
    if (_formKey.currentState!.validate() && _selectedQuality != null) {
      final harvest = HarvestModel(
        cropId: widget.crop.id ?? '',
        harvestDate: _harvestDate,
        actualYield: double.parse(_actualYieldController.text),
        yieldUnit: _selectedYieldUnit,
        quality: _selectedQuality!,
        lossAmount: _lossAmountController.text.isNotEmpty
            ? double.parse(_lossAmountController.text)
            : null,
        lossReason: _selectedLossReason == 'other_loss'
            ? _customLossReasonController.text
            : _selectedLossReason,
        storageLocation: _storageLocationController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      Navigator.pop(context, harvest);
    } else if (_selectedQuality == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select quality assessment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
