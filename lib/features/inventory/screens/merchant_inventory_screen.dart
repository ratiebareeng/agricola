import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/inventory/screens/merchant_inventory_detail_screen.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MerchantInventoryScreen extends ConsumerStatefulWidget {
  const MerchantInventoryScreen({super.key});

  @override
  ConsumerState<MerchantInventoryScreen> createState() =>
      _MerchantInventoryScreenState();
}

class _MerchantInventoryScreenState
    extends ConsumerState<MerchantInventoryScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final profile = ref.watch(profileSetupProvider);
    final isAgriShop =
        (profile.merchantType ?? MerchantType.agriShop) ==
        MerchantType.agriShop;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAgriShop
                        ? t('store_inventory', currentLang)
                        : t('produce_inventory', currentLang),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAgriShop
                        ? 'Manage your store products'
                        : 'Track your produce stock',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        const SizedBox(width: 8),
                        _buildFilterChip('In Stock'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Low Stock'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Out of Stock'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Items',
                          isAgriShop ? '47' : '12',
                          Icons.inventory_2,
                          const Color(0xFF2D6A4F),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Low Stock',
                          isAgriShop ? '6' : '3',
                          Icons.warning_amber_rounded,
                          const Color(0xFFFFBE0B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Out of Stock',
                          isAgriShop ? '2' : '0',
                          Icons.remove_circle_outline,
                          const Color(0xFFFF6B35),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  if (isAgriShop) ...[
                    _buildInventoryItem(
                      'NPK Fertiliser 2:3:2',
                      'Fertiliser',
                      '45 bags',
                      'P280/bag',
                      'In Stock',
                      Colors.green,
                      Icons.science,
                    ),
                    const SizedBox(height: 12),
                    _buildInventoryItem(
                      'Drip Irrigation Kit',
                      'Equipment',
                      '12 units',
                      'P1,200/unit',
                      'In Stock',
                      Colors.green,
                      Icons.water_drop,
                    ),
                    const SizedBox(height: 12),
                    _buildInventoryItem(
                      'Maize Seeds - Hybrid',
                      'Seeds',
                      '8 bags',
                      'P650/25kg',
                      'Low Stock',
                      Colors.orange,
                      Icons.grass,
                    ),
                    const SizedBox(height: 12),
                    _buildInventoryItem(
                      'Pesticide - 5L',
                      'Chemicals',
                      '18 bottles',
                      'P350/bottle',
                      'In Stock',
                      Colors.green,
                      Icons.sanitizer,
                    ),
                    const SizedBox(height: 12),
                    _buildInventoryItem(
                      'Hand Hoe',
                      'Tools',
                      '3 units',
                      'P120/unit',
                      'Low Stock',
                      Colors.orange,
                      Icons.construction,
                    ),
                    const SizedBox(height: 12),
                    _buildInventoryItem(
                      'Wheelbarrow',
                      'Tools',
                      '0 units',
                      'P450/unit',
                      'Out of Stock',
                      Colors.red,
                      Icons.agriculture,
                    ),
                  ] else ...[
                    _buildInventoryItem(
                      'Fresh Maize',
                      'Grains',
                      '850 kg',
                      'P4.50/kg',
                      'In Stock',
                      Colors.green,
                      Icons.grass,
                    ),
                    const SizedBox(height: 12),
                    _buildInventoryItem(
                      'Sorghum',
                      'Grains',
                      '420 kg',
                      'P5.20/kg',
                      'In Stock',
                      Colors.green,
                      Icons.grass,
                    ),
                    const SizedBox(height: 12),
                    _buildInventoryItem(
                      'Butternut',
                      'Vegetables',
                      '180 kg',
                      'P12.00/kg',
                      'In Stock',
                      Colors.green,
                      Icons.eco,
                    ),
                    const SizedBox(height: 12),
                    _buildInventoryItem(
                      'Sweet Potatoes',
                      'Vegetables',
                      '95 kg',
                      'P8.50/kg',
                      'Low Stock',
                      Colors.orange,
                      Icons.eco,
                    ),
                    const SizedBox(height: 12),
                    _buildInventoryItem(
                      'Tomatoes',
                      'Vegetables',
                      '35 kg',
                      'P15.00/kg',
                      'Low Stock',
                      Colors.orange,
                      Icons.eco,
                    ),
                    const SizedBox(height: 12),
                    _buildInventoryItem(
                      'Beans',
                      'Legumes',
                      '260 kg',
                      'P9.00/kg',
                      'In Stock',
                      Colors.green,
                      Icons.spa,
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF2D6A4F),
        icon: const Icon(Icons.add),
        label: Text(isAgriShop ? 'Add Product' : 'Add Produce'),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D6A4F) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2D6A4F) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryItem(
    String name,
    String category,
    String quantity,
    String price,
    String status,
    Color statusColor,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MerchantInventoryDetailScreen(
              name: name,
              category: category,
              quantity: quantity,
              price: price,
              status: status,
              statusColor: statusColor,
              icon: icon,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2D6A4F).withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF2D6A4F), size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    quantity,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
