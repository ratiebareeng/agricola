import 'package:agricola/core/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return Stream.periodic(const Duration(seconds: 5), (_) => null)
      .asyncMap((_) => db.pendingSyncCount());
});

final cacheSizeProvider = FutureProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db.cacheSizeBytes();
});

/// IDs of crops that were created/updated offline and are not yet synced.
final unsyncedCropIdsProvider = StreamProvider<Set<String>>((ref) {
  final db = ref.watch(databaseProvider);
  return Stream.periodic(const Duration(seconds: 5), (_) => null)
      .asyncMap((_) async {
    final rows = await (db.select(db.localCrops)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    return rows.map((r) => r.id).toSet();
  });
});

/// IDs of inventory items that were created/updated offline and are not yet synced.
final unsyncedInventoryIdsProvider = StreamProvider<Set<String>>((ref) {
  final db = ref.watch(databaseProvider);
  return Stream.periodic(const Duration(seconds: 5), (_) => null)
      .asyncMap((_) async {
    final rows = await (db.select(db.localInventory)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    return rows.map((r) => r.id).toSet();
  });
});
