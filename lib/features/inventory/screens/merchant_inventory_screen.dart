import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/crops/crop_helpers.dart';
import 'package:agricola/features/crops/providers/crop_catalog_provider.dart';
import 'package:agricola/features/home/providers/dashboard_stats_provider.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:agricola/features/inventory/providers/inventory_providers.dart';
import 'package:agricola/features/inventory/screens/add_edit_inventory_screen.dart';
import 'package:agricola/features/inventory/screens/inventory_detail_screen.dart';
import 'package:agricola/features/inventory/widgets/inventory_item_card.dart';
import 'package:agricola/features/inventory/widgets/inventory_item_card_skeleton.dart';
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
  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final catalog = ref.watch(cropCatalogProvider).valueOrNull ?? [];
    final imageMap = ref.watch(cropImageUrlProvider).valueOrNull ?? {};
    final profile = ref.watch(profileSetupProvider);
    final isAgriShop =
        (profile.merchantType ?? MerchantType.agriShop) ==
        MerchantType.agriShop;
    final inventoryAsync = ref.watch(inventoryNotifierProvider);
    final myListingsAsync = ref.watch(myListingsNotifierProvider);

    // Build set of listed inventory IDs
    final listedIds = <String>{};
    myListingsAsync.whenData((listings) {
      for (final listing in listings) {
        if (listing.inventoryId != null) {
          listedIds.add(listing.inventoryId!);
        }
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: inventoryAsync.when(
          loading: () => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: List.generate(
                4,
                (_) => const InventoryItemCardSkeleton(),
              ),
            ),
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
                    ref
                        .read(inventoryNotifierProvider.notifier)
                        .loadInventory();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(t('retry', currentLang)),
                ),
              ],
            ),
          ),
          data: (inventory) {
            final totalItems = inventory.length;
            final lowStockItems = inventory
                .where(
                  (item) =>
                      item.condition == 'needs_attention' ||
                      item.condition == 'critical',
                )
                .length;

            return Column(
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
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAgriShop
                            ? t('manage_store_products', currentLang)
                            : t('track_produce_stock', currentLang),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              label: t('total_items', currentLang),
                              value: '$totalItems',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              label: t('low_stock', currentLang),
                              value: '$lowStockItems',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: inventory.isEmpty
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
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: inventory.length,
                          itemBuilder: (context, index) {
                            final item = inventory[index];
                            return InventoryItemCard(
                              cropType: cropDisplayName(
                                item.cropType,
                                catalog,
                                currentLang,
                              ),
                              quantity: item.quantity,
                              unit: item.unit,
                              unitPrice: item.unitPrice,
                              storageDate: item.storageDate,
                              storageLocation: item.storageLocation,
                              condition: item.condition,
                              language: currentLang,
                              imageUrl: item.imageUrls.isNotEmpty
                                  ? item.imageUrls.first
                                  : imageUrlForCrop(item.cropType, imageMap),
                              isListed: listedIds.contains(item.id),
                              onTap: () async {
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        InventoryDetailScreen(item: item),
                                  ),
                                );
                                if (result == true && context.mounted) {
                                  ref
                                      .read(inventoryNotifierProvider.notifier)
                                      .loadInventory();
                                  ref
                                      .read(myListingsNotifierProvider.notifier)
                                      .loadMyListings();
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
                      child: AgriStadiumButton(
                        onPressed: () => _addInventory(context, currentLang),
                        icon: Icons.add,
                        label: isAgriShop
                              ? t('add_product', currentLang)
                              : t('add_inventory', currentLang),
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
      MaterialPageRoute(builder: (context) => const AddEditInventoryScreen()),
    );

    if (result != null && context.mounted) {
      final error = await ref
          .read(inventoryNotifierProvider.notifier)
          .addInventory(result);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t(error, lang)),
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

  Widget _buildSummaryCard({
    required String label,
    required String value,
    IconData? icon,
    Color? color,
  }) {
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
          if (icon != null) Icon(icon, color: color, size: 24),
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
