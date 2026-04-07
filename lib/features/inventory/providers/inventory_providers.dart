import 'package:agricola/core/providers/analytics_provider.dart';
import 'package:agricola/core/services/analytics_service.dart';
import 'package:agricola/core/database/daos/inventory_local_dao.dart';
import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/core/providers/connectivity_provider.dart';
import 'package:agricola/core/providers/database_provider.dart';
import 'package:agricola/core/providers/offline_settings_provider.dart';
import 'package:agricola/features/inventory/data/inventory_api_service.dart';
import 'package:agricola/features/inventory/data/inventory_offline_repository.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inventoryApiServiceProvider = Provider<InventoryApiService>((ref) {
  return InventoryApiService(ref.watch(httpClientProvider));
});

final inventoryLocalDaoProvider = Provider<InventoryLocalDao>((ref) {
  return InventoryLocalDao(ref.watch(databaseProvider));
});

final inventoryOfflineRepositoryProvider =
    Provider<InventoryOfflineRepository>((ref) {
  return InventoryOfflineRepository(
    apiService: ref.watch(inventoryApiServiceProvider),
    localDao: ref.watch(inventoryLocalDaoProvider),
    db: ref.watch(databaseProvider),
    isOnline: () => ref.read(isOnlineProvider),
    offlineEnabled: () => ref.read(offlineModeEnabledProvider),
  );
});

final inventoryNotifierProvider =
    StateNotifierProvider<InventoryNotifier, AsyncValue<List<InventoryModel>>>((ref) {
      // Re-fetch inventory when user changes
      ref.watch(currentUserProvider);
      return InventoryNotifier(
        ref.watch(inventoryOfflineRepositoryProvider),
        ref.watch(analyticsServiceProvider),
      );
    });

class InventoryNotifier extends StateNotifier<AsyncValue<List<InventoryModel>>> {
  final InventoryOfflineRepository _repository;
  final AnalyticsService _analytics;

  InventoryNotifier(this._repository, this._analytics) : super(const AsyncValue.loading()) {
    loadInventory();
  }

  Future<void> loadInventory() async {
    state = const AsyncValue.loading();
    try {
      final inventory = await _repository.getUserInventory();
      state = AsyncValue.data(inventory);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> addInventory(InventoryModel item) async {
    try {
      final created = await _repository.createInventory(item);
      final current = state.value ?? [];
      state = AsyncValue.data([created, ...current]);
      _analytics.logInventoryAdded(itemName: item.cropType);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateInventory(InventoryModel item) async {
    try {
      final updated = await _repository.updateInventory(item.id!, item);
      final current = state.value ?? [];
      state = AsyncValue.data(
        current.map((i) => i.id == item.id ? updated : i).toList(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteInventory(String id) async {
    try {
      await _repository.deleteInventory(id);
      final current = state.value ?? [];
      state = AsyncValue.data(current.where((i) => i.id != id).toList());
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
