import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/widgets/app_dialogs.dart';
import 'package:agricola/core/widgets/app_network_image.dart';
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
  int _currentImageIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  MarketplaceListing? _findLinkedListing(List<MarketplaceListing> listings) {
    if (_item.id == null) return null;
    for (final listing in listings) {
      if (listing.inventoryId == _item.id) return listing;
    }
    return null;
  }

  Color _conditionColor(String condition) {
    switch (condition) {
      case 'excellent':
        return AppColors.green;
      case 'good':
        return const Color(0xFF52A871);
      case 'fair':
        return AppColors.warmYellow;
      case 'needs_attention':
        return Colors.orange;
      case 'critical':
        return AppColors.alertRed;
      default:
        return AppColors.mediumGray;
    }
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
    final catalog = ref.watch(cropCatalogProvider).valueOrNull ?? [];
    final imageMap = ref.watch(cropImageUrlProvider).valueOrNull ?? {};
    final cropName = cropDisplayName(_item.cropType, catalog, language);
    final userPhotos = _item.imageUrls;
    final catalogUrl = userPhotos.isEmpty
        ? imageUrlForCrop(_item.cropType, imageMap)
        : '';
    final allPhotos = userPhotos.isNotEmpty
        ? userPhotos
        : (catalogUrl.isNotEmpty ? [catalogUrl] : <String>[]);
    final conditionColor = _conditionColor(_item.condition);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t('inventory_details', language),
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF1A1A1A)),
            onPressed: () => _editItem(context, language),
          ),
          IconButton(
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.alertRed),
                  )
                : const Icon(Icons.delete_outline, color: AppColors.alertRed),
            onPressed: _isDeleting
                ? null
                : () => _confirmDelete(
                      context,
                      language,
                      isListed,
                      linkedListing.valueOrNull,
                    ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero image
                  _buildHeroImage(allPhotos),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Crop name + condition
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                cropName,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              t(_item.condition, language),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: conditionColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Quantity
                        Text(
                          '${_item.quantity} ${t(_item.unit, language)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.green,
                          ),
                        ),

                        // Listed badge
                        if (isListed) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.storefront,
                                  size: 14, color: AppColors.green),
                              const SizedBox(width: 6),
                              Text(
                                t('listed_on_marketplace', language),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 24),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 24),

                        // Storage details
                        Text(
                          t('storage_info', language),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: t('storage_date', language),
                          value: dateFormat.format(_item.storageDate),
                        ),
                        const SizedBox(height: 14),
                        _buildInfoRow(
                          icon: Icons.location_on_outlined,
                          label: t('location', language),
                          value: _item.storageLocation,
                        ),
                        const SizedBox(height: 14),
                        _buildInfoRow(
                          icon: Icons.inventory_2_outlined,
                          label: t('condition', language),
                          value: t(_item.condition, language),
                          valueColor: conditionColor,
                        ),

                        // Notes
                        if (_item.notes != null && _item.notes!.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          const SizedBox(height: 24),
                          Text(
                            t('notes', language),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _item.notes!,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky bottom action
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: SafeArea(
              top: false,
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
                            icon: const Icon(Icons.storefront_outlined),
                            label: Text(t('view_listing', language)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
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
                          icon: const Icon(Icons.remove_shopping_cart_outlined),
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
                        icon: const Icon(Icons.storefront_outlined),
                        label: Text(t('list_on_marketplace', language)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(List<String> photos) {
    if (photos.isEmpty) {
      return Container(
        height: 220,
        color: Colors.grey[100],
        child: Center(
          child: Icon(
            Icons.local_florist_outlined,
            size: 72,
            color: Colors.grey[300],
          ),
        ),
      );
    }

    if (photos.length == 1) {
      return SizedBox(
        height: 220,
        width: double.infinity,
        child: AppNetworkImage(url: photos.first, height: 220),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: photos.length,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemBuilder: (context, index) => AppNetworkImage(
              url: photos[index],
              width: double.infinity,
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              photos.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: i == _currentImageIndex ? 16 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i == _currentImageIndex
                      ? Colors.white
                      : Colors.white.withAlpha(120),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ],
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
              backgroundColor: AppColors.green,
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
            backgroundColor: AppColors.green,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppLanguage language,
    bool isListed,
    MarketplaceListing? linkedListing,
  ) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: t('delete_inventory', language),
      content: isListed
          ? t('delete_inventory_listed_confirm', language)
          : t('delete_inventory_confirm', language),
      cancelText: t('cancel', language),
      actionText: isListed ? t('delete_both', language) : t('delete', language),
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      await _deleteItem(context, language, linkedListing: linkedListing);
    }
  }

  Future<void> _deleteItem(
    BuildContext context,
    AppLanguage language, {
    MarketplaceListing? linkedListing,
  }) async {
    if (_item.id == null) return;

    setState(() => _isDeleting = true);

    if (linkedListing != null) {
      final unlistError = await ref
          .read(marketplaceNotifierProvider.notifier)
          .deleteListing(linkedListing.id);
      if (unlistError != null && context.mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t(unlistError, language)),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

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
          content: Text(
            linkedListing != null
                ? t('inventory_and_listing_deleted', language)
                : t('inventory_deleted', language),
          ),
          backgroundColor: AppColors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }
}
