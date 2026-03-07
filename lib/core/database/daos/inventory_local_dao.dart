import 'dart:convert';

import 'package:agricola/core/database/app_database.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:drift/drift.dart' show Value;

class InventoryLocalDao {
  final AppDatabase _db;

  InventoryLocalDao(this._db);

  Future<List<InventoryModel>> getAll() async {
    final rows = await _db.select(_db.localInventory).get();
    return rows
        .map((r) =>
            InventoryModel.fromJson(jsonDecode(r.data) as Map<String, dynamic>))
        .toList();
  }

  Future<void> cacheAll(List<InventoryModel> items) async {
    await _db.transaction(() async {
      await _db.delete(_db.localInventory).go();
      for (final item in items) {
        await _db.into(_db.localInventory).insertOnConflictUpdate(
          LocalInventoryCompanion.insert(
            id: item.id ?? '',
            data: jsonEncode(item.toJson()),
          ),
        );
      }
    });
  }

  Future<void> upsertOne(InventoryModel item,
      {bool isSynced = true, String? localId}) async {
    final id = item.id ?? localId ?? '';
    await _db.into(_db.localInventory).insertOnConflictUpdate(
      LocalInventoryCompanion.insert(
        id: id,
        data: jsonEncode(item.toJson()),
        localId: Value(localId),
        isSynced: Value(isSynced),
      ),
    );
  }

  Future<void> deleteOne(String id) async {
    await (_db.delete(_db.localInventory)..where((t) => t.id.equals(id))).go();
  }

  Future<Set<String>> getUnsyncedIds() async {
    final rows = await (_db.select(_db.localInventory)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    return rows.map((r) => r.id).toSet();
  }
}
