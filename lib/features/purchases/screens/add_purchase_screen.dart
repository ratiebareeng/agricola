import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/features/crops/models/crop_catalog_entry.dart';
import 'package:agricola/features/crops/providers/crop_catalog_provider.dart';
import 'package:agricola/features/purchases/models/purchase_model.dart';
import 'package:agricola/features/purchases/providers/purchases_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AddPurchaseScreen extends ConsumerStatefulWidget {
  const AddPurchaseScreen({super.key});

  @override
  ConsumerState<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends ConsumerState<AddPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sellerNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _pricePerUnitController = TextEditingController();
  final _notesController = TextEditingController();

  String? _cropType;
  String _unit = 'kg';
  DateTime _purchaseDate = DateTime.now();
  bool _isSaving = false;

  final List<String> _units = ['kg', 'bags', 'tons', 'crates', 'bundles'];

  @override
  void dispose() {
    _sellerNameController.dispose();
    _quantityController.dispose();
    _pricePerUnitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    final qty = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_pricePerUnitController.text) ?? 0;
    return qty * price;
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final catalogAsync = ref.watch(cropCatalogProvider);
    final catalogEntries = catalogAsync.valueOrNull ?? <CropCatalogEntry>[];
    final cropKeys = catalogEntries.map((e) => e.key).toList();

    String cropLabel(String key) {
      final entry = catalogEntries.cast<CropCatalogEntry?>().firstWhere(
            (e) => e?.key == key,
            orElse: () => null,
          );
      return entry?.displayName(lang) ?? t(key, lang);
    }

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
          t('record_new_purchase', lang),
          style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 18),
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
                    _buildTextField(
                      controller: _sellerNameController,
                      label: t('seller_name', lang),
                      hint: t('seller_name_hint', lang),
                      icon: Icons.person_outline,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown<String>(
                      label: t('crop_type', lang),
                      icon: Icons.eco_outlined,
                      value: _cropType,
                      items: cropKeys
                          .map((k) => DropdownMenuItem(
                                value: k,
                                child: Text(cropLabel(k)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _cropType = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _quantityController,
                            label: t('quantity', lang),
                            icon: Icons.scale_outlined,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (double.tryParse(v) == null ||
                                  double.parse(v) <= 0) {
                                return 'Must be > 0';
                              }
                              return null;
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown<String>(
                            label: t('unit', lang),
                            icon: Icons.straighten,
                            value: _unit,
                            items: _units
                                .map((u) => DropdownMenuItem(
                                      value: u,
                                      child: Text(u),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _unit = v ?? 'kg'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _pricePerUnitController,
                      label: t('price_per_unit', lang),
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      prefix: 'P ',
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null ||
                            double.parse(v) <= 0) {
                          return 'Must be > 0';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    _buildTotalAmountDisplay(lang),
                    const SizedBox(height: 16),
                    _buildDatePicker(lang),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _notesController,
                      label: t('notes', lang),
                      icon: Icons.notes_outlined,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _savePurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        t('record_purchase', lang),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? prefix,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        prefixIcon: Icon(icon, color: AppColors.green),
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
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.green),
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
      ),
    );
  }

  Widget _buildTotalAmountDisplay(AppLanguage lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.green.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.green.withAlpha(50)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            t('total_amount', lang),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            'P ${_totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(AppLanguage lang) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _purchaseDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: AppColors.green),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _purchaseDate = picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: t('purchase_date', lang),
          prefixIcon:
              const Icon(Icons.calendar_today_outlined, color: AppColors.green),
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
        child: Text(
          DateFormat('dd MMM yyyy').format(_purchaseDate),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final lang = ref.read(languageProvider);
    final purchase = PurchaseModel(
      userId: '', // Backend infers from auth token
      sellerName: _sellerNameController.text.trim(),
      cropType: _cropType!,
      quantity: double.parse(_quantityController.text),
      unit: _unit,
      pricePerUnit: double.parse(_pricePerUnitController.text),
      totalAmount: _totalAmount,
      purchaseDate: _purchaseDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final error =
        await ref.read(purchasesNotifierProvider.notifier).addPurchase(purchase);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('purchase_saved', lang)),
          backgroundColor: AppColors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(error, lang)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
