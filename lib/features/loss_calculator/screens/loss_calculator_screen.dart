import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:agricola/features/crops/providers/crop_catalog_provider.dart';
import 'package:agricola/features/crops/providers/crop_providers.dart';
import 'package:agricola/features/loss_calculator/models/loss_calculation.dart';
import 'package:agricola/features/loss_calculator/providers/loss_calculator_provider.dart';
import 'package:agricola/features/loss_calculator/screens/loss_history_screen.dart';
import 'package:agricola/features/loss_calculator/widgets/loss_results_card.dart';
import 'package:agricola/features/loss_calculator/widgets/loss_stage_input.dart';
import 'package:agricola/features/loss_calculator/widgets/prevention_tips_card.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LossCalculatorScreen extends ConsumerStatefulWidget {
  /// If provided, pre-fills step 1 with this crop's data.
  final CropModel? preselectedCrop;

  const LossCalculatorScreen({super.key, this.preselectedCrop});

  @override
  ConsumerState<LossCalculatorScreen> createState() =>
      _LossCalculatorScreenState();
}

class _LossCalculatorScreenState extends ConsumerState<LossCalculatorScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1 — Crop & Harvest
  CropModel? _selectedCrop;
  final _harvestAmountController = TextEditingController();
  String _selectedUnit = 'kg';
  final _marketPriceController = TextEditingController();
  String _storageMethod = 'traditional';

  // Step 2 — Loss by Stage
  final _fieldLossController = TextEditingController();
  final _transportLossController = TextEditingController();
  final _storageLossController = TextEditingController();
  final _processingLossController = TextEditingController();
  String? _fieldCause;
  String? _transportCause;
  String? _storageCause;
  String? _processingCause;

  // Step 3 — Results
  LossCalculation? _result;
  bool _isSaving = false;
  bool _isSaved = false;

  final _units = ['kg', 'bags', 'tons'];
  final _storageMethods = [
    'traditional_granary',
    'improved_storage',
    'bags_in_room',
    'open_air',
    'warehouse',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.preselectedCrop != null) {
      _selectedCrop = widget.preselectedCrop;
      _harvestAmountController.text =
          widget.preselectedCrop!.estimatedYield.toString();
      _selectedUnit = widget.preselectedCrop!.yieldUnit;
      _storageMethod = widget.preselectedCrop!.storageMethod;
    }
  }

  @override
  void dispose() {
    _harvestAmountController.dispose();
    _marketPriceController.dispose();
    _fieldLossController.dispose();
    _transportLossController.dispose();
    _storageLossController.dispose();
    _processingLossController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(t('loss_calculator', lang)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: t('history', lang),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LossHistoryScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Step indicator
            _buildStepIndicator(lang),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _currentStep == 0
                    ? _buildStep1(lang)
                    : _currentStep == 1
                        ? _buildStep2(lang)
                        : _buildStep3(lang),
              ),
            ),
            // Bottom buttons
            _buildBottomButtons(lang),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step indicator
  // ---------------------------------------------------------------------------
  Widget _buildStepIndicator(AppLanguage lang) {
    final steps = [
      t('crop_harvest', lang),
      t('loss_details', lang),
      t('results', lang),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? const Color(0xFF2D6A4F)
                        : isActive
                            ? const Color(0xFF2D6A4F)
                            : Colors.grey[300],
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    steps[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                      color: isActive
                          ? const Color(0xFF2D6A4F)
                          : Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (i < steps.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 16,
                      height: 2,
                      color: isDone ? const Color(0xFF2D6A4F) : Colors.grey[300],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 1 — Crop & Harvest info
  // ---------------------------------------------------------------------------
  Widget _buildStep1(AppLanguage lang) {
    final cropsAsync = ref.watch(cropNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('select_crop', lang),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t('select_crop_for_calculation', lang),
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        // Crop dropdown
        cropsAsync.when(
          data: (crops) {
            if (crops.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warmYellow.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warmYellow.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.warmYellow),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t('no_crops_add_first', lang),
                        style: const TextStyle(color: AppColors.warmYellow),
                      ),
                    ),
                  ],
                ),
              );
            }

            return DropdownButtonFormField<CropModel>(
              initialValue: _selectedCrop,
              isExpanded: true,
              decoration: _inputDecoration(t('choose_crop', lang)),
              items: crops.map((crop) {
                return DropdownMenuItem(
                  value: crop,
                  child: Text(
                    '${crop.fieldName} — ${t(crop.cropType, lang)}',
                  ),
                );
              }).toList(),
              onChanged: (crop) {
                if (crop == null) return;
                setState(() {
                  _selectedCrop = crop;
                  _harvestAmountController.text =
                      crop.estimatedYield.toString();
                  _selectedUnit = crop.yieldUnit;
                  _storageMethod = crop.storageMethod;
                });
              },
              validator: (v) =>
                  v == null ? t('required', lang) : null,
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF2D6A4F)),
          ),
          error: (_, __) => Text(t('error_loading', lang)),
        ),
        const SizedBox(height: 24),

        // Harvest amount
        Text(
          t('harvest_amount', lang),
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
                controller: _harvestAmountController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('0.0'),
                validator: (v) {
                  if (v == null || v.isEmpty) return t('required', lang);
                  if (double.tryParse(v) == null) {
                    return t('enter_valid_number', lang);
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedUnit,
                decoration: _inputDecoration(null),
                items: _units.map((u) {
                  return DropdownMenuItem(value: u, child: Text(t(u, lang)));
                }).toList(),
                onChanged: (v) => setState(() => _selectedUnit = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Market price
        Text(
          t('market_price_per_unit', lang),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _marketPriceController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration('0.00').copyWith(
            prefixText: 'P ',
            suffixText: '/ ${t(_selectedUnit, lang)}',
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return t('required', lang);
            if (double.tryParse(v) == null) {
              return t('enter_valid_number', lang);
            }
            return null;
          },
        ),
        const SizedBox(height: 24),

        // Storage method
        Text(
          t('storage_method', lang),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _storageMethod,
          isExpanded: true,
          decoration: _inputDecoration(null),
          items: _storageMethods.map((m) {
            return DropdownMenuItem(value: m, child: Text(t(m, lang)));
          }).toList(),
          onChanged: (v) => setState(() => _storageMethod = v!),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2 — Loss by stage
  // ---------------------------------------------------------------------------
  Widget _buildStep2(AppLanguage lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('enter_losses_by_stage', lang),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t('enter_losses_description', lang),
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),

        LossStageInput(
          stage: 'field',
          unit: _selectedUnit,
          lang: lang,
          amountController: _fieldLossController,
          selectedCause: _fieldCause,
          onCauseChanged: (v) => setState(() => _fieldCause = v),
          icon: Icons.grass,
          color: AppColors.green,
        ),
        LossStageInput(
          stage: 'transport',
          unit: _selectedUnit,
          lang: lang,
          amountController: _transportLossController,
          selectedCause: _transportCause,
          onCauseChanged: (v) => setState(() => _transportCause = v),
          icon: Icons.local_shipping,
          color: AppColors.green,
        ),
        LossStageInput(
          stage: 'storage',
          unit: _selectedUnit,
          lang: lang,
          amountController: _storageLossController,
          selectedCause: _storageCause,
          onCauseChanged: (v) => setState(() => _storageCause = v),
          icon: Icons.warehouse,
          color: AppColors.green,
        ),
        LossStageInput(
          stage: 'processing',
          unit: _selectedUnit,
          lang: lang,
          amountController: _processingLossController,
          selectedCause: _processingCause,
          onCauseChanged: (v) => setState(() => _processingCause = v),
          icon: Icons.precision_manufacturing,
          color: AppColors.green,
        ),

        // Running total
        _buildRunningTotal(lang),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRunningTotal(AppLanguage lang) {
    final harvest = double.tryParse(_harvestAmountController.text) ?? 0;
    final totalLoss = _parseLoss(_fieldLossController) +
        _parseLoss(_transportLossController) +
        _parseLoss(_storageLossController) +
        _parseLoss(_processingLossController);
    final pct = harvest > 0 ? (totalLoss / harvest) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pct > 25
            ? AppColors.alertRed.withAlpha(15)
            : pct > 15
                ? AppColors.warmYellow.withAlpha(15)
                : AppColors.green.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: pct > 25
              ? AppColors.alertRed.withAlpha(50)
              : pct > 15
                  ? AppColors.warmYellow.withAlpha(50)
                  : AppColors.green.withAlpha(50),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            t('running_total', lang),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            '${totalLoss.toStringAsFixed(1)} ${t(_selectedUnit, lang)} (${pct.toStringAsFixed(1)}%)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: pct > 25
                  ? AppColors.alertRed
                  : pct > 15
                      ? AppColors.warmYellow
                      : AppColors.green,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 3 — Results
  // ---------------------------------------------------------------------------
  Widget _buildStep3(AppLanguage lang) {
    if (_result == null) return const SizedBox.shrink();

    final catalogAsync = ref.watch(cropCatalogByCategoryProvider);
    String cropCategory = 'default';
    catalogAsync.whenData((byCategory) {
      for (final entry in byCategory.entries) {
        if (entry.value.any((c) => c.key == _selectedCrop?.cropType)) {
          cropCategory = entry.key;
          break;
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LossResultsCard(
          calculation: _result!,
          cropCategory: cropCategory,
          lang: lang,
        ),
        const SizedBox(height: 16),
        // Save button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isSaving || _isSaved
                ? null
                : () => _saveCalculation(cropCategory),
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_isSaved ? Icons.check : Icons.save_outlined),
            label: Text(
              _isSaved ? t('saved', lang) : t('save_results', lang),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: _isSaved
                    ? const Color(0xFF2D6A4F)
                    : Colors.grey[400]!,
              ),
              foregroundColor:
                  _isSaved ? const Color(0xFF2D6A4F) : Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(height: 24),
        PreventionTipsCard(
          calculation: _result!,
          lang: lang,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom buttons
  // ---------------------------------------------------------------------------
  Widget _buildBottomButtons(AppLanguage lang) {
    return Container(
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
                onPressed: () => setState(() {
                  _currentStep--;
                  _isSaved = false;
                }),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF2D6A4F)),
                ),
                child: Text(t('back', lang)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentStep == 2
                    ? const Color(0xFF2D6A4F)
                    : const Color(0xFF2D6A4F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _currentStep == 0
                    ? t('next', lang)
                    : _currentStep == 1
                        ? t('calculate', lang)
                        : t('done', lang),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------
  void _onNext() {
    if (_currentStep == 0) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      _calculateResult();
      setState(() => _currentStep = 2);
    } else {
      Navigator.pop(context);
    }
  }

  void _calculateResult() {
    final harvest = double.tryParse(_harvestAmountController.text) ?? 0;
    final price = double.tryParse(_marketPriceController.text) ?? 0;

    final stages = <LossStage>[];

    void addStage(String name, TextEditingController ctrl, String? cause) {
      final amount = double.tryParse(ctrl.text) ?? 0;
      if (amount > 0) {
        stages.add(LossStage(stage: name, amount: amount, cause: cause));
      }
    }

    addStage('field', _fieldLossController, _fieldCause);
    addStage('transport', _transportLossController, _transportCause);
    addStage('storage', _storageLossController, _storageCause);
    addStage('processing', _processingLossController, _processingCause);

    _result = LossCalculation(
      cropType: _selectedCrop?.cropType ?? '',
      harvestAmount: harvest,
      unit: _selectedUnit,
      marketPricePerUnit: price,
      storageMethod: _storageMethod,
      stages: stages,
    );
  }

  // ---------------------------------------------------------------------------
  // Save to backend
  // ---------------------------------------------------------------------------
  Future<void> _saveCalculation(String cropCategory) async {
    if (_result == null) return;
    setState(() => _isSaving = true);

    final toSave = _result!.copyWith(
      cropCategory: cropCategory,
      calculationDate: DateTime.now(),
    );

    final error = await ref
        .read(lossCalculatorNotifierProvider.notifier)
        .saveCalculation(toSave);

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _isSaved = error == null;
    });

    if (error != null) {
      final lang = ref.read(languageProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('save_failed', lang)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  double _parseLoss(TextEditingController ctrl) {
    return double.tryParse(ctrl.text) ?? 0;
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
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
    );
  }
}
