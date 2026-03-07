import 'package:agricola/core/database/daos/crop_catalog_local_dao.dart';
import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/core/providers/connectivity_provider.dart';
import 'package:agricola/core/providers/database_provider.dart';
import 'package:agricola/features/crops/data/crop_catalog_api_service.dart';
import 'package:agricola/features/crops/models/crop_catalog_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cropCatalogApiServiceProvider = Provider<CropCatalogApiService>((ref) {
  return CropCatalogApiService(ref.watch(httpClientProvider));
});

final cropCatalogLocalDaoProvider = Provider<CropCatalogLocalDao>((ref) {
  return CropCatalogLocalDao(ref.watch(databaseProvider));
});

/// Raw list of all active catalog entries — cached locally with 7-day TTL.
final cropCatalogProvider = FutureProvider<List<CropCatalogEntry>>((ref) async {
  final service = ref.watch(cropCatalogApiServiceProvider);
  final dao = ref.watch(cropCatalogLocalDaoProvider);
  final isOnline = ref.watch(isOnlineProvider);

  // Try to serve from cache first
  final isStale = await dao.isCacheStale();

  if (isOnline && isStale) {
    // Fetch fresh data and cache it
    try {
      final entries = await service.getCatalog();
      await dao.cacheAll(entries);
      return entries;
    } catch (_) {
      // Network failed — fall back to cache
      final cached = await dao.getAll();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  // Serve from cache (fresh enough or offline)
  final cached = await dao.getAll();
  if (cached.isNotEmpty) return cached;

  // No cache and offline — try network as last resort
  if (isOnline) {
    final entries = await service.getCatalog();
    await dao.cacheAll(entries);
    return entries;
  }

  throw Exception('Crop catalog unavailable offline (no cached data)');
});

/// Catalog grouped by category
final cropCatalogByCategoryProvider =
    Provider<AsyncValue<Map<String, List<CropCatalogEntry>>>>((ref) {
  return ref.watch(cropCatalogProvider).whenData((entries) {
    final map = <String, List<CropCatalogEntry>>{};
    for (final entry in entries) {
      map.putIfAbsent(entry.category, () => []).add(entry);
    }
    return map;
  });
});

/// Harvest days lookup: key -> days
final harvestDaysProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  return ref.watch(cropCatalogProvider).whenData((entries) {
    return {for (final e in entries) e.key: e.harvestDays};
  });
});

/// Image URL lookup: key -> url
final cropImageUrlProvider =
    Provider<AsyncValue<Map<String, String>>>((ref) {
  return ref.watch(cropCatalogProvider).whenData((entries) {
    return {
      for (final e in entries)
        if (e.imageUrl != null) e.key: e.imageUrl!,
    };
  });
});
