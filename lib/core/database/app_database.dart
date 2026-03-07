import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// -- Cache tables --

class LocalCrops extends Table {
  TextColumn get id => text()();
  TextColumn get localId => text().nullable()();
  TextColumn get data => text()(); // JSON-encoded CropModel
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalInventory extends Table {
  TextColumn get id => text()();
  TextColumn get localId => text().nullable()();
  TextColumn get data => text()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalHarvests extends Table {
  TextColumn get id => text()();
  TextColumn get localId => text().nullable()();
  TextColumn get data => text()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalMarketplace extends Table {
  TextColumn get id => text()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalOrders extends Table {
  TextColumn get id => text()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalPurchases extends Table {
  TextColumn get id => text()();
  TextColumn get localId => text().nullable()();
  TextColumn get data => text()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalCropCatalog extends Table {
  IntColumn get id => integer()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// -- Sync infrastructure --

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // crop, inventory, harvest
  TextColumn get entityId => text().nullable()(); // Server ID (null for creates)
  TextColumn get localId => text()(); // Client UUID
  TextColumn get operation => text()(); // create, update, delete
  TextColumn get payload => text()(); // JSON
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // pending, in_progress, failed, completed
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get errorMessage => text().nullable()();
}

class SyncMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [
  LocalCrops,
  LocalInventory,
  LocalHarvests,
  LocalMarketplace,
  LocalOrders,
  LocalPurchases,
  LocalCropCatalog,
  SyncQueue,
  SyncMetadata,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Add offline CRUD columns to LocalPurchases
            await m.addColumn(localPurchases, localPurchases.localId);
            await m.addColumn(localPurchases, localPurchases.isSynced);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'agricola_offline');
  }

  // -- Sync Queue operations --

  Future<int> addToSyncQueue({
    required String entityType,
    String? entityId,
    required String localId,
    required String operation,
    required Map<String, dynamic> payload,
  }) {
    return into(syncQueue).insert(SyncQueueCompanion.insert(
      entityType: entityType,
      entityId: Value(entityId),
      localId: localId,
      operation: operation,
      payload: jsonEncode(payload),
    ));
  }

  Future<List<SyncQueueData>> getPendingSyncItems() {
    return (select(syncQueue)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  Future<void> updateSyncItemStatus(
    int id,
    String status, {
    String? errorMessage,
  }) {
    return (update(syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        status: Value(status),
        errorMessage: Value(errorMessage),
        retryCount: status == 'failed'
            ? const Value.absent() // incremented separately
            : const Value.absent(),
      ),
    );
  }

  Future<void> incrementRetryCount(int id) async {
    await customStatement(
      'UPDATE sync_queue SET retry_count = retry_count + 1 WHERE id = ?',
      [id],
    );
  }

  Future<void> clearCompletedSyncItems() {
    return (delete(syncQueue)..where((t) => t.status.equals('completed'))).go();
  }

  Future<int> pendingSyncCount() async {
    final count = countAll();
    final query = selectOnly(syncQueue)
      ..where(syncQueue.status.equals('pending') |
          syncQueue.status.equals('failed'))
      ..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // -- Local ID mapping --

  /// After a create syncs, update the cache table to use the server ID
  /// and update any dependent sync queue items.
  Future<void> replaceLocalId({
    required String entityType,
    required String localId,
    required String serverId,
  }) async {
    await transaction(() async {
      // Update the cache table
      switch (entityType) {
        case 'crop':
          await (update(localCrops)..where((t) => t.id.equals(localId)))
              .write(LocalCropsCompanion(
            id: Value(serverId),
            localId: Value(localId),
            isSynced: const Value(true),
          ));
        case 'inventory':
          await (update(localInventory)..where((t) => t.id.equals(localId)))
              .write(LocalInventoryCompanion(
            id: Value(serverId),
            localId: Value(localId),
            isSynced: const Value(true),
          ));
        case 'harvest':
          await (update(localHarvests)..where((t) => t.id.equals(localId)))
              .write(LocalHarvestsCompanion(
            id: Value(serverId),
            localId: Value(localId),
            isSynced: const Value(true),
          ));
        case 'purchase':
          await (update(localPurchases)..where((t) => t.id.equals(localId)))
              .write(LocalPurchasesCompanion(
            id: Value(serverId),
            localId: Value(localId),
            isSynced: const Value(true),
          ));
      }

      // Update dependent sync queue items that reference this local ID
      final dependents = await (select(syncQueue)
            ..where((t) =>
                t.status.equals('pending') &
                t.payload.contains(localId)))
          .get();

      for (final item in dependents) {
        final updatedPayload =
            item.payload.replaceAll(localId, serverId);
        await (update(syncQueue)..where((t) => t.id.equals(item.id)))
            .write(SyncQueueCompanion(payload: Value(updatedPayload)));
      }
    });
  }

  // -- Cache helpers --

  Future<void> cacheList<T extends Table, D>(
    TableInfo<T, D> table,
    List<Map<String, dynamic>> items,
    String idField,
  ) async {
    await transaction(() async {
      await delete(table).go();
      for (final item in items) {
        final id = item[idField]?.toString() ?? '';
        if (table == localCrops) {
          await into(localCrops).insertOnConflictUpdate(LocalCropsCompanion.insert(
            id: id,
            data: jsonEncode(item),
          ));
        } else if (table == localInventory) {
          await into(localInventory).insertOnConflictUpdate(LocalInventoryCompanion.insert(
            id: id,
            data: jsonEncode(item),
          ));
        } else if (table == localHarvests) {
          await into(localHarvests).insertOnConflictUpdate(LocalHarvestsCompanion.insert(
            id: id,
            data: jsonEncode(item),
          ));
        } else if (table == localMarketplace) {
          await into(localMarketplace).insertOnConflictUpdate(LocalMarketplaceCompanion.insert(
            id: id,
            data: jsonEncode(item),
          ));
        } else if (table == localOrders) {
          await into(localOrders).insertOnConflictUpdate(LocalOrdersCompanion.insert(
            id: id,
            data: jsonEncode(item),
          ));
        } else if (table == localPurchases) {
          await into(localPurchases).insertOnConflictUpdate(LocalPurchasesCompanion.insert(
            id: id,
            data: jsonEncode(item),
          ));
        }
      }
    });
  }

  // -- Cache size --

  /// Returns total cached data size in bytes (approximate).
  Future<int> cacheSizeBytes() async {
    Future<int> rowCount<T extends HasResultSet>(ResultSetImplementation<T, dynamic> table) async {
      final count = countAll();
      final query = selectOnly(table)..addColumns([count]);
      final result = await query.getSingle();
      return result.read(count) ?? 0;
    }

    int total = 0;
    total += await rowCount(localCrops);
    total += await rowCount(localInventory);
    total += await rowCount(localHarvests);
    total += await rowCount(localMarketplace);
    total += await rowCount(localOrders);
    total += await rowCount(localPurchases);
    total += await rowCount(localCropCatalog);
    return total * 500; // ~500 bytes per JSON row estimate
  }

  /// Delete all cached data and sync queue.
  Future<void> clearAllCache() async {
    await transaction(() async {
      await delete(localCrops).go();
      await delete(localInventory).go();
      await delete(localHarvests).go();
      await delete(localMarketplace).go();
      await delete(localOrders).go();
      await delete(localPurchases).go();
      await delete(localCropCatalog).go();
      await delete(syncQueue).go();
      await delete(syncMetadata).go();
    });
  }

  // -- Eviction --

  /// Remove cached data older than [days] days.
  Future<void> evictOldCache({int days = 90}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    await (delete(localCrops)..where((t) => t.cachedAt.isSmallerThanValue(cutoff))).go();
    await (delete(localInventory)..where((t) => t.cachedAt.isSmallerThanValue(cutoff))).go();
    await (delete(localHarvests)..where((t) => t.cachedAt.isSmallerThanValue(cutoff))).go();
    await (delete(localMarketplace)..where((t) => t.cachedAt.isSmallerThanValue(cutoff))).go();
    await (delete(localOrders)..where((t) => t.cachedAt.isSmallerThanValue(cutoff))).go();
    await (delete(localPurchases)..where((t) => t.cachedAt.isSmallerThanValue(cutoff))).go();
    await (delete(syncQueue)..where((t) => t.status.equals('completed'))).go();
  }
}
