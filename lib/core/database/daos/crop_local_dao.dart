import 'dart:convert';

import 'package:agricola/core/database/app_database.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:drift/drift.dart';

class CropLocalDao {
  final AppDatabase _db;

  CropLocalDao(this._db);

  Future<List<CropModel>> getAll() async {
    final rows = await _db.select(_db.localCrops).get();
    return rows
        .map((r) => CropModel.fromJson(jsonDecode(r.data) as Map<String, dynamic>))
        .toList();
  }

  Future<void> cacheAll(List<CropModel> crops) async {
    await _db.transaction(() async {
      await _db.delete(_db.localCrops).go();
      for (final crop in crops) {
        await _db.into(_db.localCrops).insertOnConflictUpdate(
          LocalCropsCompanion.insert(
            id: crop.id ?? '',
            data: jsonEncode(crop.toJson()),
          ),
        );
      }
    });
  }

  Future<void> upsertOne(CropModel crop, {bool isSynced = true, String? localId}) async {
    final id = crop.id ?? localId ?? '';
    await _db.into(_db.localCrops).insertOnConflictUpdate(
      LocalCropsCompanion.insert(
        id: id,
        data: jsonEncode(crop.toJson()),
        localId: Value(localId),
        isSynced: Value(isSynced),
      ),
    );
  }

  Future<void> deleteOne(String id) async {
    await (_db.delete(_db.localCrops)..where((t) => t.id.equals(id))).go();
  }

  Future<Set<String>> getUnsyncedIds() async {
    final rows = await (_db.select(_db.localCrops)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    return rows.map((r) => r.id).toSet();
  }
}
