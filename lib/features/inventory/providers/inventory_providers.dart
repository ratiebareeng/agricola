import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/features/inventory/data/inventory_api_service.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inventoryApiServiceProvider = Provider<InventoryApiService>((ref) {
  return InventoryApiService(ref.watch(httpClientProvider));
});

final inventoryNotifierProvider =
    StateNotifierProvider<InventoryNotifier, AsyncValue<List<InventoryModel>>>((ref) {
      return InventoryNotifier(ref.watch(inventoryApiServiceProvider));
    });

class InventoryNotifier extends StateNotifier<AsyncValue<List<InventoryModel>>> {
  final InventoryApiService _service;

  InventoryNotifier(this._service) : super(const AsyncValue.loading()) {
    loadInventory();
  }

  /// Fetch inventory from the backend. Sets state to error if the request fails.
  Future<void> loadInventory() async {
    state = const AsyncValue.loading();
    try {
      final inventory = await _service.getUserInventory();
      state = AsyncValue.data(inventory);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add an inventory item. Returns null on success, error message on failure.
  Future<String?> addInventory(InventoryModel item) async {
    try {
      final created = await _service.createInventory(item);
      final current = state.value ?? [];
      state = AsyncValue.data([created, ...current]);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Update an inventory item. Returns null on success, error message on failure.
  Future<String?> updateInventory(InventoryModel item) async {
    try {
      final updated = await _service.updateInventory(item.id!, item);
      final current = state.value ?? [];
      state = AsyncValue.data(
        current.map((i) => i.id == item.id ? updated : i).toList(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Delete an inventory item. Returns null on success, error message on failure.
  Future<String?> deleteInventory(String id) async {
    try {
      await _service.deleteInventory(id);
      final current = state.value ?? [];
      state = AsyncValue.data(current.where((i) => i.id != id).toList());
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
