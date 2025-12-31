import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:agricola/features/inventory/widgets/inventory_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FarmerInventoryScreen extends ConsumerStatefulWidget {
  const FarmerInventoryScreen({super.key});

  @override
  ConsumerState<FarmerInventoryScreen> createState() =>
      _FarmerInventoryScreenState();
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? const Color(0xFF2D6A4F);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: buttonColor.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: buttonColor.withAlpha(30)),
        ),
        child: Row(
          children: [
            Icon(icon, color: buttonColor),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FarmerInventoryScreenState extends ConsumerState<FarmerInventoryScreen> {
  String? _selectedCropFilter;
  String? _selectedLocationFilter;

  final List<InventoryModel> _sampleInventory = [
    InventoryModel(
      id: '1',
      cropType: 'maize',
      quantity: 350,
      unit: 'kg',
      storageDate: DateTime.now().subtract(const Duration(days: 15)),
      storageLocation: 'Warehouse A',
      condition: 'excellent',
    ),
    InventoryModel(
      id: '2',
      cropType: 'sorghum',
      quantity: 200,
      unit: 'kg',
      storageDate: DateTime.now().subtract(const Duration(days: 45)),
      storageLocation: 'Traditional Granary',
      condition: 'good',
    ),
    InventoryModel(
      id: '3',
      cropType: 'beans',
      quantity: 120,
      unit: 'kg',
      storageDate: DateTime.now().subtract(const Duration(days: 80)),
      storageLocation: 'Home Storage',
      condition: 'needs_attention',
    ),
    InventoryModel(
      id: '4',
      cropType: 'cowpeas',
      quantity: 85,
      unit: 'kg',
      storageDate: DateTime.now().subtract(const Duration(days: 120)),
      storageLocation: 'Warehouse A',
      condition: 'critical',
    ),
    InventoryModel(
      id: '5',
      cropType: 'maize',
      quantity: 180,
      unit: 'kg',
      storageDate: DateTime.now().subtract(const Duration(days: 30)),
      storageLocation: 'Warehouse B',
      condition: 'good',
    ),
  ];

  Set<String> get _availableLocations {
    return _sampleInventory.map((item) => item.storageLocation).toSet();
  }

  List<InventoryModel> get _filteredInventory {
    return _sampleInventory.where((item) {
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

  int get _itemsNeedingAttention {
    return _filteredInventory
        .where(
          (item) =>
              item.condition == 'needs_attention' ||
              item.condition == 'critical',
        )
        .length;
  }

  double get _totalValue {
    return _filteredInventory.fold(
      0,
      (sum, item) => sum + (item.quantity * 2.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final filteredItems = _filteredInventory;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
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
                                'P ${_totalValue.toStringAsFixed(2)}',
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
                                '$_itemsNeedingAttention',
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
                          onTap: () =>
                              _showFilterBottomSheet(context, currentLang),
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
                            t('add_inventory', currentLang),
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
                          onTap: () =>
                              _showItemActions(context, currentLang, item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, AppLanguage lang) {
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
                children: [
                  'maize', 'sorghum', 'wheat', 'beans', 'cowpeas', 
                  'tomatoes', 'onions', 'cabbage', 'watermelon'
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
                children: _availableLocations
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

  void _showItemActions(
    BuildContext context,
    AppLanguage lang,
    InventoryModel item,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory_2, color: Colors.grey[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t(item.cropType, lang),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${item.quantity} ${t(item.unit, lang)}',
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
            const SizedBox(height: 20),
            _ActionButton(
              icon: Icons.edit,
              label: t('update_quantity', lang),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.warning_amber,
              label: t('record_loss', lang),
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.shopping_cart,
              label: t('record_sale', lang),
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
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
