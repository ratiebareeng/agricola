import 'package:agricola/core/utils/error_utils.dart';
import 'package:agricola/core/providers/analytics_provider.dart';
import 'package:agricola/core/database/daos/marketplace_local_dao.dart';
import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/core/providers/connectivity_provider.dart';
import 'package:agricola/core/providers/database_provider.dart';
import 'package:agricola/core/providers/offline_settings_provider.dart';
import 'package:agricola/features/marketplace/data/marketplace_api_service.dart';
import 'package:agricola/features/marketplace/models/marketplace_filter.dart';
import 'package:agricola/features/marketplace/models/marketplace_listing.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/home/providers/dashboard_stats_provider.dart';
import 'package:agricola/features/inventory/providers/inventory_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// API Service provider
final marketplaceApiServiceProvider = Provider<MarketplaceApiService>((ref) {
  return MarketplaceApiService(ref.watch(httpClientProvider));
});

final marketplaceLocalDaoProvider = Provider<MarketplaceLocalDao>((ref) {
  return MarketplaceLocalDao(ref.watch(databaseProvider));
});

// Filter state provider (UI state, separate from data)
final marketplaceFilterProvider = StateProvider<MarketplaceFilter>((ref) {
  return const MarketplaceFilter();
});

// Main data provider with AsyncValue
final marketplaceNotifierProvider = StateNotifierProvider<MarketplaceNotifier,
    AsyncValue<List<MarketplaceListing>>>((ref) {
  // Re-fetch marketplace when user changes
  ref.watch(currentUserProvider);
  return MarketplaceNotifier(
    ref: ref,
    service: ref.watch(marketplaceApiServiceProvider),
    localDao: ref.watch(marketplaceLocalDaoProvider),
    isOnline: () => ref.read(isOnlineProvider),
    offlineEnabled: () => ref.read(offlineModeEnabledProvider),
  );
});

class MarketplaceNotifier
    extends StateNotifier<AsyncValue<List<MarketplaceListing>>> {
  final Ref _ref;
  final MarketplaceApiService _service;
  final MarketplaceLocalDao _localDao;
  final bool Function() _isOnline;
  final bool Function() _offlineEnabled;

  MarketplaceNotifier({
    required Ref ref,
    required MarketplaceApiService service,
    required MarketplaceLocalDao localDao,
    required bool Function() isOnline,
    required bool Function() offlineEnabled,
  })  : _ref = ref,
        _service = service,
        _localDao = localDao,
        _isOnline = isOnline,
        _offlineEnabled = offlineEnabled,
        super(const AsyncValue.loading()) {
    loadListings();
  }

  /// No automatic type filter — all users see all listings.
  /// Users can filter by type via the filter sheet.
  ListingType? _getListingTypeForUser() => null;

  /// Load listings from backend (or local cache when offline)
  Future<void> loadListings() async {
    state = const AsyncValue.loading();
    try {
      if (_offlineEnabled() && !_isOnline()) {
        final cached = await _localDao.getAll();
        state = AsyncValue.data(cached);
        return;
      }

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

      if (_offlineEnabled()) await _localDao.cacheAll(listings);
      state = AsyncValue.data(listings);
    } catch (e, st) {
      if (_offlineEnabled()) {
        // Network error while offline mode on — serve stale cache if available
        final cached = await _localDao.getAll();
        if (cached.isNotEmpty) {
          state = AsyncValue.data(cached);
          return;
        }
      }
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

  void _invalidateListingCaches() {
    _ref.invalidate(myListingsNotifierProvider);
    _ref.invalidate(inventoryNotifierProvider);
  }

  /// Add a listing. Returns null on success, error message on failure.
  Future<String?> addListing(MarketplaceListing listing) async {
    try {
      final created = await _service.createListing(listing);
      final current = state.value ?? [];
      state = AsyncValue.data([created, ...current]);
      _ref.read(analyticsServiceProvider).logListingCreated();
      _invalidateListingCaches();
      return null;
    } catch (e) {
      return errorKeyFromException(e);
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
      _invalidateListingCaches();
      return null;
    } catch (e) {
      return errorKeyFromException(e);
    }
  }

  /// Delete a listing. Returns null on success, error message on failure.
  Future<String?> deleteListing(String id) async {
    try {
      await _service.deleteListing(id);
      final current = state.value ?? [];
      state = AsyncValue.data(current.where((l) => l.id != id).toList());
      _invalidateListingCaches();
      return null;
    } catch (e) {
      return errorKeyFromException(e);
    }
  }
}
