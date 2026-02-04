import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:agricola/features/inventory/providers/inventory_providers.dart';
import 'package:agricola/features/inventory/screens/add_edit_inventory_screen.dart';
import 'package:agricola/features/inventory/screens/inventory_detail_screen.dart';
import 'package:agricola/features/inventory/widgets/inventory_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FarmerInventoryScreen extends ConsumerStatefulWidget {
  const FarmerInventoryScreen({super.key});

  @override
  ConsumerState<FarmerInventoryScreen> createState() =>
      _FarmerInventoryScreenState();
}

class _FarmerInventoryScreenState extends ConsumerState<FarmerInventoryScreen> {
  String? _selectedCropFilter;
  String? _selectedLocationFilter;

  Set<String> _getAvailableLocations(List<InventoryModel> inventory) {
    return inventory.map((item) => item.storageLocation).toSet();
  }

  List<InventoryModel> _filterInventory(List<InventoryModel> inventory) {
    return inventory.where((item) {
      if (_selectedCropFilter != null && item.cropType != _selectedCropFilter) {
        return false;
      }
      if (_selectedLocationFilter != null &&
          item.storageLocation != _selectedLocationFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  int _countItemsNeedingAttention(List<InventoryModel> filteredInventory) {
    return filteredInventory
        .where(
          (item) =>
              item.condition == 'needs_attention' ||
              item.condition == 'critical',
        )
        .length;
  }

  double _calculateTotalValue(List<InventoryModel> filteredInventory) {
    return filteredInventory.fold(
      0,
      (sum, item) => sum + (item.quantity * 2.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final inventoryAsync = ref.watch(inventoryNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: inventoryAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF2D6A4F)),
          ),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  t('error_loading_inventory', currentLang),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    ref.read(inventoryNotifierProvider.notifier).loadInventory();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(t('retry', currentLang)),
                ),
              ],
            ),
          ),
          data: (inventory) {
            final filteredItems = _filterInventory(inventory);
            final availableLocations = _getAvailableLocations(inventory);
            final itemsNeedingAttention = _countItemsNeedingAttention(filteredItems);
            final totalValue = _calculateTotalValue(filteredItems);

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('inventory_view', currentLang),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.withAlpha(10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet,
                                        size: 18,
                                        color: Colors.green[700],
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        t('total_value', currentLang),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'P ${totalValue.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.withAlpha(10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber,
                                        size: 18,
                                        color: Colors.orange[700],
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          t('items_needing_attention', currentLang),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange[700],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$itemsNeedingAttention',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: t('filters', currentLang),
                              icon: Icons.filter_list,
                              isActive:
                                  _selectedCropFilter != null ||
                                  _selectedLocationFilter != null,
                              onTap: () => _showFilterBottomSheet(
                                context,
                                currentLang,
                                availableLocations,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_selectedCropFilter != null) ...[
                              _FilterChip(
                                label: t(_selectedCropFilter!, currentLang),
                                icon: Icons.grass,
                                isActive: true,
                                showClose: true,
                                onTap: () {
                                  setState(() => _selectedCropFilter = null);
                                },
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (_selectedLocationFilter != null) ...[
                              _FilterChip(
                                label: _selectedLocationFilter!,
                                icon: Icons.location_on,
                                isActive: true,
                                showClose: true,
                                onTap: () {
                                  setState(() => _selectedLocationFilter = null);
                                },
                              ),
                              const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                t('no_inventory', currentLang),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t('add_inventory_hint', currentLang),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return InventoryItemCard(
                              cropType: item.cropType,
                              quantity: item.quantity,
                              unit: item.unit,
                              storageDate: item.storageDate,
                              storageLocation: item.storageLocation,
                              condition: item.condition,
                              language: currentLang,
                              onTap: () async {
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        InventoryDetailScreen(item: item),
                                  ),
                                );
                                if (result == true && context.mounted) {
                                  ref.read(inventoryNotifierProvider.notifier).loadInventory();
                                }
                              },
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _addInventory(context, currentLang),
                        icon: const Icon(Icons.add),
                        label: Text(t('add_inventory', currentLang)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D6A4F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _addInventory(BuildContext context, AppLanguage lang) async {
    final result = await Navigator.push<InventoryModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditInventoryScreen(),
      ),
    );

    if (result != null && context.mounted) {
      final error = await ref.read(inventoryNotifierProvider.notifier).addInventory(result);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t('error', lang)}: $error'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('inventory_added', lang)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showFilterBottomSheet(
    BuildContext context,
    AppLanguage lang,
    Set<String> availableLocations,
  ) {
    String? tempCropFilter = _selectedCropFilter;
    String? tempLocationFilter = _selectedLocationFilter;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t('filters', lang),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        tempCropFilter = null;
                        tempLocationFilter = null;
                      });
                    },
                    child: Text(t('clear_filters', lang)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                t('crop_type', lang),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                          'maize',
                          'sorghum',
                          'wheat',
                          'beans',
                          'cowpeas',
                          'tomatoes',
                          'onions',
                          'cabbage',
                          'watermelon',
                        ]
                        .map(
                          (crop) => FilterChip(
                            label: Text(t(crop, lang)),
                            selected: tempCropFilter == crop,
                            onSelected: (selected) {
                              setModalState(() {
                                tempCropFilter = selected ? crop : null;
                              });
                            },
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 20),
              Text(
                t('storage_location', lang),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableLocations
                    .map(
                      (location) => FilterChip(
                        label: Text(location),
                        selected: tempLocationFilter == location,
                        onSelected: (selected) {
                          setModalState(() {
                            tempLocationFilter = selected ? location : null;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCropFilter = tempCropFilter;
                      _selectedLocationFilter = tempLocationFilter;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(t('apply_filters', lang)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool showClose;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    this.showClose = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2D6A4F) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF2D6A4F) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              showClose ? Icons.close : icon,
              size: 16,
              color: isActive ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
