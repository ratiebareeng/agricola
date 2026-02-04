import 'dart:async';

import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/marketplace/models/marketplace_filter.dart';
import 'package:agricola/features/marketplace/models/marketplace_listing.dart';
import 'package:agricola/features/marketplace/providers/marketplace_provider.dart';
import 'package:agricola/features/marketplace/screens/marketplace_detail_screen.dart';
import 'package:agricola/features/marketplace/widgets/marketplace_filter_bottom_sheet.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final listingsAsync = ref.watch(marketplaceNotifierProvider);
    final filter = ref.watch(marketplaceFilterProvider);
    final profileState = ref.watch(profileSetupProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          t('marketplace', currentLang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () => _showFilterBottomSheet(context),
                icon: const Icon(Icons.filter_list),
              ),
              if (filter.activeFilterCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${filter.activeFilterCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(currentLang),
          _buildCategoryHint(currentLang, profileState),
          _buildActiveFilterChips(currentLang, filter),
          Expanded(
            child: listingsAsync.when(
              data: (listings) => listings.isEmpty
                  ? _buildEmptyState(currentLang)
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(marketplaceNotifierProvider.notifier).refresh(),
                      color: AppColors.green,
                      child: _buildListingsList(listings),
                    ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.green),
              ),
              error: (error, _) => _buildErrorState(currentLang, error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChips(AppLanguage lang, MarketplaceFilter filter) {
    if (!filter.hasActiveFilters || filter.activeFilterCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (filter.minPrice != null || filter.maxPrice != null)
              _buildFilterChip(
                label: _formatPriceRange(filter, lang),
                onRemove: () {
                  ref.read(marketplaceFilterProvider.notifier).state =
                      filter.copyWith(clearMinPrice: true, clearMaxPrice: true);
                  ref.read(marketplaceNotifierProvider.notifier).loadListings();
                },
              ),
            if (filter.category != null) ...[
              if (filter.minPrice != null || filter.maxPrice != null)
                const SizedBox(width: 8),
              _buildFilterChip(
                label: filter.category!,
                onRemove: () {
                  ref.read(marketplaceFilterProvider.notifier).state =
                      filter.copyWith(clearCategory: true);
                  ref.read(marketplaceNotifierProvider.notifier).loadListings();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({required String label, required VoidCallback onRemove}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPriceRange(MarketplaceFilter filter, AppLanguage lang) {
    if (filter.minPrice != null && filter.maxPrice != null) {
      return 'P${filter.minPrice!.toStringAsFixed(0)} - P${filter.maxPrice!.toStringAsFixed(0)}';
    } else if (filter.minPrice != null) {
      return '${t('min_price', lang)}: P${filter.minPrice!.toStringAsFixed(0)}';
    } else if (filter.maxPrice != null) {
      return '${t('max_price', lang)}: P${filter.maxPrice!.toStringAsFixed(0)}';
    }
    return '';
  }

  Widget _buildErrorState(AppLanguage lang, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              t('error_loading', lang),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(marketplaceNotifierProvider.notifier).loadListings(),
              icon: const Icon(Icons.refresh),
              label: Text(t('retry', lang)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => const MarketplaceFilterBottomSheet(),
    );
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final currentFilter = ref.read(marketplaceFilterProvider);
      ref.read(marketplaceFilterProvider.notifier).state =
          currentFilter.copyWith(searchQuery: query);
      ref.read(marketplaceNotifierProvider.notifier).loadListings();
    });
  }

  Widget _buildCategoryHint(AppLanguage lang, ProfileSetupState profile) {
    String hint;
    if (profile.userType == UserType.farmer) {
      hint = t('farmer_marketplace_hint', lang);
    } else if (profile.merchantType == MerchantType.agriShop) {
      hint = t('merchant_marketplace_hint', lang);
    } else {
      hint = t('vendor_marketplace_hint', lang);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.green.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20, color: AppColors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hint,
              style: const TextStyle(fontSize: 13, color: AppColors.darkGray),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLanguage lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            t('no_results', lang),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t('try_different_search', lang),
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard(MarketplaceListing listing) {
    final currentLang = ref.watch(languageProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MarketplaceDetailScreen(listing: listing),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              listing.location,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (listing.status != null)
                    _buildStatusBadge(listing.status!, currentLang),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                listing.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      listing.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (listing.quantity != null)
                    Text(
                      listing.quantity!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (listing.price != null)
                        Text(
                          'P ${listing.price!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.green,
                          ),
                        ),
                      if (listing.unit != null)
                        Text(
                          listing.unit!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        listing.sellerName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (listing.harvestDate != null)
                        Text(
                          '${t('harvest', currentLang)}: ${listing.harvestDate}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingsList(List<MarketplaceListing> listings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        return _buildListingCard(listings[index]);
      },
    );
  }

  Widget _buildSearchBar(AppLanguage lang) {
    final profileState = ref.watch(profileSetupProvider);
    final String hint = profileState.userType == UserType.farmer
        ? t('search_supplies', lang)
        : t('search_produce', lang);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search, color: AppColors.green),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    final currentFilter = ref.read(marketplaceFilterProvider);
                    ref.read(marketplaceFilterProvider.notifier).state =
                        currentFilter.copyWith(searchQuery: '');
                    ref.read(marketplaceNotifierProvider.notifier).loadListings();
                    setState(() {});
                  },
                )
              : null,
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
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onChanged: (value) {
          _onSearchChanged(value);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildStatusBadge(CropStatus status, AppLanguage lang) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case CropStatus.harvested:
        color = Colors.green;
        label = t('harvested', lang);
        icon = Icons.check_circle;
        break;
      case CropStatus.readyToHarvest:
        color = Colors.orange;
        label = t('ready_soon', lang);
        icon = Icons.schedule;
        break;
      case CropStatus.growing:
        color = Colors.blue;
        label = t('growing', lang);
        icon = Icons.grass;
        break;
      case CropStatus.planted:
        color = Colors.grey;
        label = t('planted', lang);
        icon = Icons.spa;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
