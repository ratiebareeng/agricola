import 'dart:convert';

import 'package:agricola/core/database/app_database.dart';
import 'package:agricola/features/crops/models/harvest_model.dart';
import 'package:drift/drift.dart' show Value;

class HarvestLocalDao {
  final AppDatabase _db;

  HarvestLocalDao(this._db);

  Future<List<HarvestModel>> getByCropId(String cropId) async {
    final rows = await _db.select(_db.localHarvests).get();
    return rows
        .map((r) =>
            HarvestModel.fromJson(jsonDecode(r.data) as Map<String, dynamic>))
        .where((h) => h.cropId == cropId)
        .toList();
  }

  Future<void> cacheForCrop(String cropId, List<HarvestModel> harvests) async {
    await _db.transaction(() async {
      // Remove existing harvests for this crop
      final existing = await _db.select(_db.localHarvests).get();
      for (final row in existing) {
        final h = HarvestModel.fromJson(
            jsonDecode(row.data) as Map<String, dynamic>);
        if (h.cropId == cropId) {
          await (_db.delete(_db.localHarvests)
                ..where((t) => t.id.equals(row.id)))
              .go();
        }
      }
      // Insert fresh
      for (final harvest in harvests) {
        await _db.into(_db.localHarvests).insertOnConflictUpdate(
          LocalHarvestsCompanion.insert(
            id: harvest.id ?? '',
            data: jsonEncode(harvest.toJson()),
          ),
        );
      }
    });
  }

  Future<void> upsertOne(HarvestModel harvest,
      {bool isSynced = true, String? localId}) async {
    final id = harvest.id ?? localId ?? '';
    await _db.into(_db.localHarvests).insertOnConflictUpdate(
      LocalHarvestsCompanion.insert(
        id: id,
        data: jsonEncode(harvest.toJson()),
        localId: Value(localId),
        isSynced: Value(isSynced),
      ),
    );
  }

  Future<void> deleteOne(String id) async {
    await (_db.delete(_db.localHarvests)..where((t) => t.id.equals(id))).go();
  }
}
