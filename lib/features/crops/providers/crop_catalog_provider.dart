import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/features/crops/data/crop_catalog_api_service.dart';
import 'package:agricola/features/crops/models/crop_catalog_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cropCatalogApiServiceProvider = Provider<CropCatalogApiService>((ref) {
  return CropCatalogApiService(ref.watch(httpClientProvider));
});

/// Raw list of all active catalog entries
final cropCatalogProvider = FutureProvider<List<CropCatalogEntry>>((ref) async {
  final service = ref.watch(cropCatalogApiServiceProvider);
  return service.getCatalog();
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
