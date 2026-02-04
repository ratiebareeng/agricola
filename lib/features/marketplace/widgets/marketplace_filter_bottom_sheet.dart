import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/features/marketplace/providers/marketplace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketplaceFilterBottomSheet extends ConsumerStatefulWidget {
  const MarketplaceFilterBottomSheet({super.key});

  @override
  ConsumerState<MarketplaceFilterBottomSheet> createState() =>
      _MarketplaceFilterBottomSheetState();
}

class _MarketplaceFilterBottomSheetState
    extends ConsumerState<MarketplaceFilterBottomSheet> {
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  String? _tempCategory;

  static const List<String> _categories = [
    'Grains',
    'Vegetables',
    'Fruits',
    'Fertiliser',
    'Seeds',
    'Tools',
    'Irrigation Equipment',
  ];

  @override
  void initState() {
    super.initState();
    final currentFilter = ref.read(marketplaceFilterProvider);
    _minPriceController = TextEditingController(
      text: currentFilter.minPrice?.toStringAsFixed(0) ?? '',
    );
    _maxPriceController = TextEditingController(
      text: currentFilter.maxPrice?.toStringAsFixed(0) ?? '',
    );
    _tempCategory = currentFilter.category;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with clear button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('filters', currentLang),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearAllFilters,
                child: Text(
                  t('clear_filters', currentLang),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Price Range Section
          Text(
            t('price_range', currentLang),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  decoration: InputDecoration(
                    labelText: t('min_price', currentLang),
                    prefixText: 'P ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  decoration: InputDecoration(
                    labelText: t('max_price', currentLang),
                    prefixText: 'P ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Category Section
          Text(
            t('category', currentLang),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              final isSelected = _tempCategory == category;
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _tempCategory = selected ? category : null;
                  });
                },
                selectedColor: AppColors.green.withValues(alpha: 0.2),
                checkmarkColor: AppColors.green,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                t('apply_filters', currentLang),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _applyFilters() {
    final minPrice = double.tryParse(_minPriceController.text);
    final maxPrice = double.tryParse(_maxPriceController.text);

    final currentFilter = ref.read(marketplaceFilterProvider);
    ref.read(marketplaceFilterProvider.notifier).state = currentFilter.copyWith(
      minPrice: minPrice,
      maxPrice: maxPrice,
      category: _tempCategory,
      clearMinPrice: minPrice == null,
      clearMaxPrice: maxPrice == null,
      clearCategory: _tempCategory == null,
    );
    ref.read(marketplaceNotifierProvider.notifier).loadListings();
    Navigator.pop(context);
  }

  void _clearAllFilters() {
    setState(() {
      _minPriceController.clear();
      _maxPriceController.clear();
      _tempCategory = null;
    });
  }
}
