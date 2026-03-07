import 'dart:convert';

import 'package:agricola/core/database/app_database.dart';
import 'package:agricola/features/crops/models/crop_catalog_entry.dart';
import 'package:drift/drift.dart' show Value;

class CropCatalogLocalDao {
  final AppDatabase _db;

  CropCatalogLocalDao(this._db);

  Future<List<CropCatalogEntry>> getAll() async {
    final rows = await _db.select(_db.localCropCatalog).get();
    return rows
        .map((r) =>
            CropCatalogEntry.fromJson(jsonDecode(r.data) as Map<String, dynamic>))
        .toList();
  }

  Future<void> cacheAll(List<CropCatalogEntry> entries) async {
    await _db.transaction(() async {
      await _db.delete(_db.localCropCatalog).go();
      for (final entry in entries) {
        await _db.into(_db.localCropCatalog).insert(
          LocalCropCatalogCompanion.insert(
            id: Value(entry.id),
            data: jsonEncode(entry.toJson()),
          ),
        );
      }
    });
    // Store cache timestamp
    await _db.into(_db.syncMetadata).insertOnConflictUpdate(
      SyncMetadataCompanion.insert(
        key: 'crop_catalog_cached_at',
        value: DateTime.now().toIso8601String(),
      ),
    );
  }

  Future<bool> isCacheStale({Duration ttl = const Duration(days: 7)}) async {
    final row = await (_db.select(_db.syncMetadata)
          ..where((t) => t.key.equals('crop_catalog_cached_at')))
        .getSingleOrNull();
    if (row == null) return true;
    final cachedAt = DateTime.tryParse(row.value);
    if (cachedAt == null) return true;
    return DateTime.now().difference(cachedAt) > ttl;
  }
}
