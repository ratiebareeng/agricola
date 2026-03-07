import 'package:agricola/core/database/app_database.dart';
import 'package:agricola/core/database/daos/inventory_local_dao.dart';
import 'package:agricola/features/inventory/data/inventory_api_service.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class InventoryOfflineRepository {
  final InventoryApiService _apiService;
  final InventoryLocalDao _localDao;
  final AppDatabase _db;
  final bool Function() _isOnline;
  final bool Function() _offlineEnabled;

  InventoryOfflineRepository({
    required InventoryApiService apiService,
    required InventoryLocalDao localDao,
    required AppDatabase db,
    required bool Function() isOnline,
    required bool Function() offlineEnabled,
  })  : _apiService = apiService,
        _localDao = localDao,
        _db = db,
        _isOnline = isOnline,
        _offlineEnabled = offlineEnabled;

  Future<List<InventoryModel>> getUserInventory() async {
    if (!_offlineEnabled()) return _apiService.getUserInventory();

    if (_isOnline()) {
      try {
        final items = await _apiService.getUserInventory();
        await _localDao.cacheAll(items);
        return items;
      } catch (_) {
        return _localDao.getAll();
      }
    }
    return _localDao.getAll();
  }

  Future<InventoryModel> createInventory(InventoryModel item) async {
    if (!_offlineEnabled() || _isOnline()) {
      final created = await _apiService.createInventory(item);
      if (_offlineEnabled()) await _localDao.upsertOne(created);
      return created;
    }

    final localId = 'local_${_uuid.v4()}';
    final offlineItem = item.copyWith(id: localId);
    await _localDao.upsertOne(offlineItem, isSynced: false, localId: localId);
    await _db.addToSyncQueue(
      entityType: 'inventory',
      localId: localId,
      operation: 'create',
      payload: item.toJson(),
    );
    return offlineItem;
  }

  Future<InventoryModel> updateInventory(String id, InventoryModel item) async {
    if (!_offlineEnabled() || _isOnline()) {
      final updated = await _apiService.updateInventory(id, item);
      if (_offlineEnabled()) await _localDao.upsertOne(updated);
      return updated;
    }

    final updatedItem = item.copyWith(id: id, updatedAt: DateTime.now());
    await _localDao.upsertOne(updatedItem, isSynced: false);
    await _db.addToSyncQueue(
      entityType: 'inventory',
      entityId: id,
      localId: id,
      operation: 'update',
      payload: updatedItem.toJson(),
    );
    return updatedItem;
  }

  Future<void> deleteInventory(String id) async {
    if (!_offlineEnabled() || _isOnline()) {
      await _apiService.deleteInventory(id);
      if (_offlineEnabled()) await _localDao.deleteOne(id);
      return;
    }

    await _localDao.deleteOne(id);
    if (!id.startsWith('local_')) {
      await _db.addToSyncQueue(
        entityType: 'inventory',
        entityId: id,
        localId: id,
        operation: 'delete',
        payload: {},
      );
    }
  }
}
