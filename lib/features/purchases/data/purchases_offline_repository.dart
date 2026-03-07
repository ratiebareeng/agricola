import 'package:agricola/core/database/app_database.dart';
import 'package:agricola/core/database/daos/purchases_local_dao.dart';
import 'package:agricola/features/purchases/data/purchases_api_service.dart';
import 'package:agricola/features/purchases/models/purchase_model.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class PurchasesOfflineRepository {
  final PurchasesApiService _apiService;
  final PurchasesLocalDao _localDao;
  final AppDatabase _db;
  final bool Function() _isOnline;
  final bool Function() _offlineEnabled;

  PurchasesOfflineRepository({
    required PurchasesApiService apiService,
    required PurchasesLocalDao localDao,
    required AppDatabase db,
    required bool Function() isOnline,
    required bool Function() offlineEnabled,
  })  : _apiService = apiService,
        _localDao = localDao,
        _db = db,
        _isOnline = isOnline,
        _offlineEnabled = offlineEnabled;

  Future<List<PurchaseModel>> getPurchases() async {
    if (!_offlineEnabled()) return _apiService.getPurchases();

    if (_isOnline()) {
      try {
        final purchases = await _apiService.getPurchases();
        await _localDao.cacheAll(purchases);
        return purchases;
      } catch (_) {
        return _localDao.getAll();
      }
    }
    return _localDao.getAll();
  }

  Future<PurchaseModel> createPurchase(PurchaseModel purchase) async {
    if (!_offlineEnabled() || _isOnline()) {
      final created = await _apiService.createPurchase(purchase);
      if (_offlineEnabled()) await _localDao.upsertOne(created);
      return created;
    }

    final localId = 'local_${_uuid.v4()}';
    final offlinePurchase = purchase.copyWith(id: localId);
    await _localDao.upsertOne(offlinePurchase, isSynced: false, localId: localId);
    await _db.addToSyncQueue(
      entityType: 'purchase',
      localId: localId,
      operation: 'create',
      payload: purchase.toJson(),
    );
    return offlinePurchase;
  }

  Future<PurchaseModel> updatePurchase(String id, PurchaseModel purchase) async {
    if (!_offlineEnabled() || _isOnline()) {
      final updated = await _apiService.updatePurchase(id, purchase);
      if (_offlineEnabled()) await _localDao.upsertOne(updated);
      return updated;
    }

    final updatedPurchase = purchase.copyWith(id: id, updatedAt: DateTime.now());
    await _localDao.upsertOne(updatedPurchase, isSynced: false);
    await _db.addToSyncQueue(
      entityType: 'purchase',
      entityId: id,
      localId: id,
      operation: 'update',
      payload: updatedPurchase.toJson(),
    );
    return updatedPurchase;
  }

  Future<void> deletePurchase(String id) async {
    if (!_offlineEnabled() || _isOnline()) {
      await _apiService.deletePurchase(id);
      if (_offlineEnabled()) await _localDao.deleteOne(id);
      return;
    }

    await _localDao.deleteOne(id);
    if (!id.startsWith('local_')) {
      await _db.addToSyncQueue(
        entityType: 'purchase',
        entityId: id,
        localId: id,
        operation: 'delete',
        payload: {},
      );
    }
  }
}
