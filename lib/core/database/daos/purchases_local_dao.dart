import 'dart:convert';

import 'package:agricola/core/database/app_database.dart';
import 'package:agricola/features/purchases/models/purchase_model.dart';
import 'package:drift/drift.dart' show Value;

class PurchasesLocalDao {
  final AppDatabase _db;

  PurchasesLocalDao(this._db);

  Future<List<PurchaseModel>> getAll() async {
    final rows = await _db.select(_db.localPurchases).get();
    return rows
        .map((r) =>
            PurchaseModel.fromJson(jsonDecode(r.data) as Map<String, dynamic>))
        .toList();
  }

  Future<void> cacheAll(List<PurchaseModel> purchases) async {
    await _db.transaction(() async {
      await _db.delete(_db.localPurchases).go();
      for (final purchase in purchases) {
        await _db.into(_db.localPurchases).insertOnConflictUpdate(
          LocalPurchasesCompanion.insert(
            id: purchase.id ?? '',
            data: jsonEncode(purchase.toJson()),
          ),
        );
      }
    });
  }

  Future<void> upsertOne(PurchaseModel purchase,
      {bool isSynced = true, String? localId}) async {
    final id = purchase.id ?? localId ?? '';
    await _db.into(_db.localPurchases).insertOnConflictUpdate(
      LocalPurchasesCompanion.insert(
        id: id,
        data: jsonEncode(purchase.toJson()),
        localId: Value(localId),
        isSynced: Value(isSynced),
      ),
    );
  }

  Future<void> deleteOne(String id) async {
    await (_db.delete(_db.localPurchases)..where((t) => t.id.equals(id))).go();
  }

  Future<Set<String>> getUnsyncedIds() async {
    final rows = await (_db.select(_db.localPurchases)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    return rows.map((r) => r.id).toSet();
  }
}
