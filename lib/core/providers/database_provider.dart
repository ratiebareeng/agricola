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
