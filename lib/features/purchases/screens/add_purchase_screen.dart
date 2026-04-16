import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:agricola/core/widgets/app_form_layout.dart';
import 'package:agricola/core/widgets/app_text_field.dart';
import 'package:agricola/core/widgets/app_dropdown_field.dart';
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

    return AppFormLayout(
      title: t('record_new_purchase', lang),
      submitLabel: t('record_purchase', lang).toUpperCase(),
      onSubmit: _isSaving ? null : _savePurchase,
      isLoading: _isSaving,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _sellerNameController,
              label: t('seller_name', lang),
              hint: t('seller_name_hint', lang),
              prefixIcon: Icons.person_outline,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            AppDropdownField<String>(
              hint: t('crop_type', lang),
              prefixIcon: const Icon(Icons.eco_outlined, color: AppColors.forestGreen, size: 20),
              value: _cropType,
              items: cropKeys,
              itemLabelBuilder: (k) => cropLabel(k),
              onChanged: (v) => setState(() => _cropType = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: AppTextField(
                    controller: _quantityController,
                    label: t('quantity', lang),
                    prefixIcon: Icons.scale_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null || double.parse(v) <= 0) {
                        return 'Must be > 0';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: AppDropdownField<String>(
                      value: _unit,
                      items: _units,
                      itemLabelBuilder: (u) => u,
                      onChanged: (v) => setState(() => _unit = v ?? 'kg'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppTextField(
              controller: _pricePerUnitController,
              label: t('price_per_unit', lang),
              prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.number,
              hint: 'P 0.00',
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null || double.parse(v) <= 0) {
                  return 'Must be > 0';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 32),
            AgriFocusCard(
              color: AppColors.deepEmerald,
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AgriMetricDisplay(
                    value: 'P${_totalAmount.toStringAsFixed(0)}',
                    label: t('total_amount', lang),
                    valueColor: AppColors.bone,
                    labelColor: AppColors.bone.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildDatePicker(lang),
            const SizedBox(height: 24),
            AppTextField(
              controller: _notesController,
              label: t('notes', lang),
              prefixIcon: Icons.notes_outlined,
              maxLines: 3,
              hint: 'Optional notes...',
            ),
            const SizedBox(height: 40),
          ],
        ),
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
                colorScheme: const ColorScheme.light(
                  primary: AppColors.forestGreen,
                  onPrimary: AppColors.white,
                  surface: AppColors.bone,
                  onSurface: AppColors.deepEmerald,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.forestGreen,
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _purchaseDate = picked);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 8),
            child: Text(
              t('purchase_date', lang).toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.deepEmerald.withValues(alpha: 0.4),
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: AppColors.forestGreen, size: 20),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd MMM yyyy').format(_purchaseDate),
                  style: const TextStyle(fontSize: 16, color: AppColors.deepEmerald, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
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
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    final error = await ref.read(purchasesNotifierProvider.notifier).addPurchase(purchase);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('purchase_saved', lang)),
          backgroundColor: AppColors.forestGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(error, lang)),
          backgroundColor: AppColors.alertRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
