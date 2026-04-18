import 'dart:async';

import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/utils/url_utils.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/marketplace/models/marketplace_filter.dart';
import 'package:agricola/features/marketplace/models/marketplace_listing.dart';
import 'package:agricola/features/marketplace/providers/marketplace_provider.dart';
import 'package:agricola/features/marketplace/screens/marketplace_detail_screen.dart';
import 'package:agricola/features/marketplace/widgets/marketplace_filter_bottom_sheet.dart';
import 'package:agricola/features/marketplace/widgets/marketplace_listing_skeleton.dart';
import 'package:agricola/core/widgets/app_image_cache.dart';
import 'package:agricola/features/marketplace/screens/crop_availability_screen.dart';
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
  bool _precached = false;

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final listingsAsync = ref.watch(marketplaceNotifierProvider);
    final filter = ref.watch(marketplaceFilterProvider);
    final profileState = ref.watch(profileSetupProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t('marketplace', currentLang),
          style: Theme.of(context).textTheme.displaySmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.grass_outlined),
            tooltip: t('crop_availability', currentLang),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CropAvailabilityScreen(),
              ),
            ),
          ),
          _FilterAction(filter: filter, onShowFilters: () => _showFilterBottomSheet(context)),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(currentLang),
          _buildCategoryHint(currentLang, profileState),
          _buildActiveFilterChips(currentLang, filter),
          Expanded(
            child: listingsAsync.when(
              data: (listings) {
                if (!_precached && listings.isNotEmpty) {
                  _precached = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      precacheNetworkImages(
                        context,
                        listings.map((l) => l.imagePath ?? ''),
                      );
                    }
                  });
                }
                return listings.isEmpty
                    ? _buildEmptyState(currentLang)
                    : RefreshIndicator(
                        onRefresh: () {
                          _precached = false;
                          return ref.read(marketplaceNotifierProvider.notifier).refresh();
                        },
                        color: AppColors.forestGreen,
                        child: _buildListingsList(listings),
                      );
              },
              loading: () => ListView(
                padding: const EdgeInsets.all(24),
                children: List.generate(4, (_) => const MarketplaceListingSkeleton()),
              ),
              error: (error, _) => _buildErrorState(currentLang, error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Widget _buildActiveFilterChips(AppLanguage lang, MarketplaceFilter filter) {
    if (!filter.hasActiveFilters || filter.activeFilterCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
              if (filter.minPrice != null || filter.maxPrice != null) const SizedBox(width: 8),
              _buildFilterChip(
                label: filter.category!,
                onRemove: () {
                  ref.read(marketplaceFilterProvider.notifier).state = filter.copyWith(clearCategory: true);
                  ref.read(marketplaceNotifierProvider.notifier).loadListings();
                },
              ),
            ],
          ],
        ),
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.forestGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hint,
              style: TextStyle(fontSize: 12, color: AppColors.deepEmerald.withValues(alpha: 0.5), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLanguage lang) {
    final filter = ref.watch(marketplaceFilterProvider);
    final hasFilters = filter.hasActiveFilters;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.search_off : Icons.storefront_outlined,
            size: 80,
            color: AppColors.deepEmerald.withValues(alpha: 0.05),
          ),
          const SizedBox(height: 16),
          Text(
            t(hasFilters ? 'no_results' : 'marketplace_empty', lang),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.deepEmerald.withValues(alpha: 0.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLanguage lang, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.alertRed),
            const SizedBox(height: 16),
            Text(t('error_loading', lang), style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            AgriStadiumButton(
              onPressed: () => ref.read(marketplaceNotifierProvider.notifier).loadListings(),
              label: t('retry', lang),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({required String label, required VoidCallback onRemove}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.forestGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 10, color: AppColors.forestGreen, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.forestGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard(MarketplaceListing listing) {
    final currentLang = ref.watch(languageProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: AgriFocusCard(
        padding: const EdgeInsets.all(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MarketplaceDetailScreen(listing: listing)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail with high radius
                Builder(builder: (context) {
                  final imageUrl = listing.imagePath;
                  final hasImage = imageUrl != null && isNetworkUrl(imageUrl);
                  return Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.bone,
                      image: hasImage
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                              onError: (_, __) {},
                            )
                          : null,
                    ),
                    child: hasImage ? null : const Icon(Icons.storefront_outlined, color: AppColors.forestGreen, size: 32),
                  );
                }),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.deepEmerald),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: AppColors.deepEmerald.withValues(alpha: 0.3)),
                          const SizedBox(width: 4),
                          Text(
                            listing.location,
                            style: TextStyle(fontSize: 12, color: AppColors.deepEmerald.withValues(alpha: 0.4), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (listing.status != null) _buildStatusBadge(listing.status!, currentLang),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              listing.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: AppColors.deepEmerald.withValues(alpha: 0.7), height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (listing.price != null)
                      Text(
                        'P${listing.price!.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.deepEmerald),
                      ),
                    if (listing.unit != null)
                      Text(
                        listing.unit!.toUpperCase(),
                        style: TextStyle(fontSize: 10, color: AppColors.forestGreen.withValues(alpha: 0.5), fontWeight: FontWeight.w800, letterSpacing: 1),
                      ),
                  ],
                ),
                AgriStadiumButton(
                  label: 'VIEW',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MarketplaceDetailScreen(listing: listing)),
                    );
                  },
                  isPrimary: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingsList(List<MarketplaceListing> listings) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        return _buildListingCard(listings[index]);
      },
    );
  }

  Widget _buildSearchBar(AppLanguage lang) {
    final profileState = ref.watch(profileSetupProvider);
    final String hint = profileState.userType == UserType.farmer ? t('search_supplies', lang) : t('search_produce', lang);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.deepEmerald),
        decoration: InputDecoration(
          hintText: hint.toUpperCase(),
          hintStyle: TextStyle(fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.w800, color: AppColors.deepEmerald.withValues(alpha: 0.2)),
          prefixIcon: const Icon(Icons.search, color: AppColors.forestGreen),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    final currentFilter = ref.read(marketplaceFilterProvider);
                    ref.read(marketplaceFilterProvider.notifier).state = currentFilter.copyWith(searchQuery: '');
                    ref.read(marketplaceNotifierProvider.notifier).loadListings();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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

    switch (status) {
      case CropStatus.harvested:
        color = AppColors.forestGreen;
        label = t('harvested', lang);
        break;
      case CropStatus.readyToHarvest:
        color = AppColors.earthYellow;
        label = t('ready_soon', lang);
        break;
      case CropStatus.growing:
        color = AppColors.forestGreen;
        label = t('growing', lang);
        break;
      case CropStatus.planted:
        color = AppColors.mediumGray;
        label = t('planted', lang);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5),
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

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final currentFilter = ref.read(marketplaceFilterProvider);
      ref.read(marketplaceFilterProvider.notifier).state = currentFilter.copyWith(searchQuery: query);
      ref.read(marketplaceNotifierProvider.notifier).loadListings();
    });
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      isScrollControlled: true,
      builder: (context) => const MarketplaceFilterBottomSheet(),
    );
  }
}

class _FilterAction extends StatelessWidget {
  final MarketplaceFilter filter;
  final VoidCallback onShowFilters;

  const _FilterAction({required this.filter, required this.onShowFilters});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          IconButton(onPressed: onShowFilters, icon: const Icon(Icons.tune, color: AppColors.deepEmerald)),
          if (filter.activeFilterCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.earthYellow, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '${filter.activeFilterCount}',
                  style: const TextStyle(color: AppColors.deepEmerald, fontSize: 10, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
