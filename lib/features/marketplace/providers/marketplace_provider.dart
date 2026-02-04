import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/features/marketplace/data/marketplace_api_service.dart';
import 'package:agricola/features/marketplace/models/marketplace_filter.dart';
import 'package:agricola/features/marketplace/models/marketplace_listing.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// API Service provider
final marketplaceApiServiceProvider = Provider<MarketplaceApiService>((ref) {
  return MarketplaceApiService(ref.watch(httpClientProvider));
});

// Filter state provider (UI state, separate from data)
final marketplaceFilterProvider = StateProvider<MarketplaceFilter>((ref) {
  return const MarketplaceFilter();
});

// Main data provider with AsyncValue
final marketplaceNotifierProvider = StateNotifierProvider<MarketplaceNotifier,
    AsyncValue<List<MarketplaceListing>>>((ref) {
  final service = ref.watch(marketplaceApiServiceProvider);
  return MarketplaceNotifier(ref, service);
});

class MarketplaceNotifier
    extends StateNotifier<AsyncValue<List<MarketplaceListing>>> {
  final Ref _ref;
  final MarketplaceApiService _service;

  MarketplaceNotifier(this._ref, this._service)
      : super(const AsyncValue.loading()) {
    loadListings();
  }

  /// Determine the listing type filter based on user type
  ListingType? _getListingTypeForUser() {
    final profileState = _ref.read(profileSetupProvider);
    if (profileState.userType == UserType.farmer) {
      return ListingType.supplies; // Farmers see supplies
    } else if (profileState.userType == UserType.merchant) {
      return ListingType.produce; // Merchants see produce
    }
    return null; // Default: see all
  }

  /// Load listings from backend with current filters
  Future<void> loadListings() async {
    state = const AsyncValue.loading();
    try {
      final filter = _ref.read(marketplaceFilterProvider);
      final userTypeFilter = _getListingTypeForUser();

      // Merge user-type filter with user-selected filters
      final effectiveFilter = filter.copyWith(
        itemType: userTypeFilter,
      );

      final listings = await _service.getListings(filter: effectiveFilter);

      // Sort: available items first, then by creation date
      listings.sort((a, b) {
        if (a.isAvailableNow && !b.isAvailableNow) return -1;
        if (!a.isAvailableNow && b.isAvailableNow) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

      state = AsyncValue.data(listings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Refresh listings (pull-to-refresh)
  Future<void> refresh() => loadListings();

  /// Clear all filters and reload
  void clearFilters() {
    _ref.read(marketplaceFilterProvider.notifier).state =
        const MarketplaceFilter();
    loadListings();
  }

  /// Add a listing. Returns null on success, error message on failure.
  Future<String?> addListing(MarketplaceListing listing) async {
    try {
      final created = await _service.createListing(listing);
      final current = state.value ?? [];
      state = AsyncValue.data([created, ...current]);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Update a listing. Returns null on success, error message on failure.
  Future<String?> updateListing(MarketplaceListing listing) async {
    try {
      final updated = await _service.updateListing(listing.id, listing);
      final current = state.value ?? [];
      state = AsyncValue.data(
        current.map((l) => l.id == listing.id ? updated : l).toList(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Delete a listing. Returns null on success, error message on failure.
  Future<String?> deleteListing(String id) async {
    try {
      await _service.deleteListing(id);
      final current = state.value ?? [];
      state = AsyncValue.data(current.where((l) => l.id != id).toList());
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
