import 'package:agricola/core/providers/language_provider.dart';
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

  bool get _isEditing => widget.existingItem != null;

  final List<String> _cropTypes = [
    'maize',
    'sorghum',
    'wheat',
    'beans',
    'cowpeas',
    'groundnuts',
    'sunflower',
    'tomatoes',
    'onions',
    'cabbage',
    'watermelon',
    'potatoes',
    'carrots',
  ];

  final List<String> _units = ['kg', 'bags', 'tons'];

  final List<String> _conditions = [
    'excellent',
    'good',
    'fair',
    'needs_attention',
    'critical',
  ];

  final List<String> _storageLocations = [
    'Warehouse A',
    'Warehouse B',
    'Traditional Granary',
    'Home Storage',
    'Cold Storage',
    'Silo',
  ];

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
      _cropType = _cropTypes.first;
      _quantity = 0;
      _unit = _units.first;
      _storageDate = DateTime.now();
      _storageLocation = _storageLocations.first;
      _condition = 'good';
      _notes = null;
    }
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
          _isEditing
              ? t('edit_inventory', currentLang)
              : t('add_inventory', currentLang),
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
                    _buildSectionTitle(t('crop_type', currentLang)),
                    const SizedBox(height: 8),
                    _buildDropdownField(
                      value: _cropType,
                      items: _cropTypes,
                      onChanged: (value) {
                        if (value != null) setState(() => _cropType = value);
                      },
                      labelBuilder: (item) => t(item, currentLang),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle(t('quantity', currentLang)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: _isEditing ? _quantity.toString() : '',
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: t('enter_quantity', currentLang),
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
                            ),
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
                            onSaved: (value) {
                              _quantity = double.parse(value!);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdownField(
                            value: _unit,
                            items: _units,
                            onChanged: (value) {
                              if (value != null) setState(() => _unit = value);
                            },
                            labelBuilder: (item) => item,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle(t('storage_date', currentLang)),
                    const SizedBox(height: 8),
                    _buildDateField(currentLang),
                    const SizedBox(height: 20),
                    _buildSectionTitle(t('storage_location', currentLang)),
                    const SizedBox(height: 8),
                    _buildDropdownField(
                      value: _storageLocation,
                      items: _storageLocations,
                      onChanged: (value) {
                        if (value != null) setState(() => _storageLocation = value);
                      },
                      labelBuilder: (item) => item,
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle(t('condition', currentLang)),
                    const SizedBox(height: 8),
                    _buildConditionSelector(currentLang),
                    const SizedBox(height: 20),
                    _buildSectionTitle('${t('notes', currentLang)} (${t('optional', currentLang)})'),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: _notes,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: t('add_notes', currentLang),
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
                      ),
                      onSaved: (value) {
                        _notes = value?.isEmpty == true ? null : value;
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveInventory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing
                        ? t('update_inventory', currentLang)
                        : t('save_inventory', currentLang),
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

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String Function(String) labelBuilder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(labelBuilder(item)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateField(AppLanguage lang) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _storageDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _storageDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: Color(0xFF2D6A4F)),
            const SizedBox(width: 12),
            Text(
              _formatDate(_storageDate),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
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
              color: isSelected ? color.withAlpha(30) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getConditionIcon(condition),
                  size: 16,
                  color: isSelected ? color : Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  t(condition, lang),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? color : Colors.grey[700],
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
        return Colors.green[500]!;
      case 'fair':
        return Colors.orange[600]!;
      case 'needs_attention':
        return Colors.orange[800]!;
      case 'critical':
        return Colors.red[700]!;
      default:
        return Colors.grey[600]!;
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
