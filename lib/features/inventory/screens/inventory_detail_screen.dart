import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/widgets/app_dialogs.dart';
import 'package:agricola/features/crops/crop_helpers.dart';
import 'package:agricola/features/crops/providers/crop_catalog_provider.dart';
import 'package:agricola/features/home/providers/dashboard_stats_provider.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:agricola/features/inventory/providers/inventory_providers.dart';
import 'package:agricola/features/inventory/screens/add_edit_inventory_screen.dart';
import 'package:agricola/features/marketplace/models/marketplace_listing.dart';
import 'package:agricola/features/marketplace/providers/marketplace_provider.dart';
import 'package:agricola/features/marketplace/screens/add_product_screen.dart';
import 'package:agricola/features/marketplace/screens/marketplace_detail_screen.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class InventoryDetailScreen extends ConsumerStatefulWidget {
  final InventoryModel item;

  const InventoryDetailScreen({super.key, required this.item});

  @override
  ConsumerState<InventoryDetailScreen> createState() =>
      _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends ConsumerState<InventoryDetailScreen> {
  late InventoryModel _item;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  MarketplaceListing? _findLinkedListing(List<MarketplaceListing> listings) {
    if (_item.id == null) return null;
    for (final listing in listings) {
      if (listing.inventoryId == _item.id) return listing;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final dateFormat = DateFormat.yMMMd();
    final myListingsAsync = ref.watch(myListingsNotifierProvider);
    final linkedListing = myListingsAsync.whenData(
      (listings) => _findLinkedListing(listings),
    );
    final isListed = linkedListing.valueOrNull != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('inventory_details', language)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editItem(context, language),
          ),
          IconButton(
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete),
            onPressed: _isDeleting ? null : () => _confirmDelete(context, language),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(context),
                  const SizedBox(height: 24),
                  _buildHeader(context, language),
                  const SizedBox(height: 24),
                  _buildDetailSection(
                    context,
                    title: t('storage_info', language),
                    children: [
                      _buildDetailRow(
                        context,
                        icon: Icons.calendar_today,
                        label: t('storage_date', language),
                        value: dateFormat.format(_item.storageDate),
                      ),
                      _buildDetailRow(
                        context,
                        icon: Icons.location_on,
                        label: t('location', language),
                        value: _item.storageLocation,
                      ),
                      _buildDetailRow(
                        context,
                        icon: Icons.info_outline,
                        label: t('condition', language),
                        value: t(_item.condition, language),
                      ),
                    ],
                  ),
                  if (_item.notes != null && _item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildDetailSection(
                      context,
                      title: t('notes', language),
                      children: [
                        Text(_item.notes!, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: isListed
                  ? Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final linked = linkedListing.valueOrNull;
                              if (linked != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MarketplaceDetailScreen(
                                            listing: linked),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.storefront),
                            label: Text(t('view_listing', language)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D6A4F),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _confirmUnlist(
                            context,
                            language,
                            linkedListing.valueOrNull!,
                          ),
                          icon: const Icon(Icons.remove_shopping_cart),
                          label: Text(t('unlist', language)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _listOnMarketplace(context),
                        icon: const Icon(Icons.storefront),
                        label: Text(t('list_on_marketplace', language)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D6A4F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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

  Future<void> _listOnMarketplace(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(sourceInventory: _item),
      ),
    );
    if (result == true && context.mounted) {
      ref.read(myListingsNotifierProvider.notifier).loadMyListings();
    }
  }

  Future<void> _confirmUnlist(
    BuildContext context,
    AppLanguage language,
    MarketplaceListing listing,
  ) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: t('unlist', language),
      content: t('unlist_confirm', language),
      cancelText: t('cancel', language),
      actionText: t('unlist', language),
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      final error = await ref
          .read(marketplaceNotifierProvider.notifier)
          .deleteListing(listing.id);
      if (context.mounted) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t(error, language)),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ref.read(myListingsNotifierProvider.notifier).loadMyListings();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t('unlisted_success', language)),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  Future<void> _editItem(BuildContext context, AppLanguage language) async {
    final result = await Navigator.push<InventoryModel>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditInventoryScreen(existingItem: _item),
      ),
    );

    if (result != null && context.mounted) {
      final error = await ref
          .read(inventoryNotifierProvider.notifier)
          .updateInventory(result);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t(error, language)),
            backgroundColor: Colors.red,
          ),
        );
      } else if (context.mounted) {
        setState(() {
          _item = result;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('inventory_updated', language)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, AppLanguage language) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: t('delete_inventory', language),
      content: t('delete_inventory_confirm', language),
      cancelText: t('cancel', language),
      actionText: t('delete', language),
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      await _deleteItem(context, language);
    }
  }

  Future<void> _deleteItem(BuildContext context, AppLanguage language) async {
    if (_item.id == null) return;

    setState(() => _isDeleting = true);

    final error = await ref
        .read(inventoryNotifierProvider.notifier)
        .deleteInventory(_item.id!);

    if (!context.mounted) return;

    setState(() => _isDeleting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(error, language)),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('inventory_deleted', language)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppLanguage language) {
    final catalog = ref.watch(cropCatalogProvider).valueOrNull ?? [];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.green.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green.withAlpha(30)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.green.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2,
              color: AppColors.green,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cropDisplayName(_item.cropType, catalog, language),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_item.quantity} ${t(_item.unit, language)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          Icons.inventory_2,
          size: 64,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
