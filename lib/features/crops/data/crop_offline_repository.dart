import 'package:agricola/core/database/app_database.dart';
import 'package:agricola/core/database/daos/crop_local_dao.dart';
import 'package:agricola/features/crops/data/crop_api_service.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class CropOfflineRepository {
  final CropApiService _apiService;
  final CropLocalDao _localDao;
  final AppDatabase _db;
  final bool Function() _isOnline;
  final bool Function() _offlineEnabled;

  CropOfflineRepository({
    required CropApiService apiService,
    required CropLocalDao localDao,
    required AppDatabase db,
    required bool Function() isOnline,
    required bool Function() offlineEnabled,
  })  : _apiService = apiService,
        _localDao = localDao,
        _db = db,
        _isOnline = isOnline,
        _offlineEnabled = offlineEnabled;

  Future<List<CropModel>> getUserCrops() async {
    if (!_offlineEnabled()) return _apiService.getUserCrops();

    if (_isOnline()) {
      try {
        final crops = await _apiService.getUserCrops();
        await _localDao.cacheAll(crops);
        return crops;
      } catch (_) {
        return _localDao.getAll();
      }
    }
    return _localDao.getAll();
  }

  Future<CropModel> createCrop(CropModel crop) async {
    if (!_offlineEnabled() || _isOnline()) {
      final created = await _apiService.createCrop(crop);
      if (_offlineEnabled()) await _localDao.upsertOne(created);
      return created;
    }

    final localId = 'local_${_uuid.v4()}';
    final offlineCrop = crop.copyWith(id: localId);
    await _localDao.upsertOne(offlineCrop, isSynced: false, localId: localId);
    await _db.addToSyncQueue(
      entityType: 'crop',
      localId: localId,
      operation: 'create',
      payload: crop.toJson(),
    );
    return offlineCrop;
  }

  Future<CropModel> updateCrop(String id, CropModel crop) async {
    if (!_offlineEnabled() || _isOnline()) {
      final updated = await _apiService.updateCrop(id, crop);
      if (_offlineEnabled()) await _localDao.upsertOne(updated);
      return updated;
    }

    final updatedCrop = crop.copyWith(id: id, updatedAt: DateTime.now());
    await _localDao.upsertOne(updatedCrop, isSynced: false);
    await _db.addToSyncQueue(
      entityType: 'crop',
      entityId: id,
      localId: id,
      operation: 'update',
      payload: updatedCrop.toJson(),
    );
    return updatedCrop;
  }

  Future<void> deleteCrop(String id) async {
    if (!_offlineEnabled() || _isOnline()) {
      await _apiService.deleteCrop(id);
      if (_offlineEnabled()) await _localDao.deleteOne(id);
      return;
    }

    await _localDao.deleteOne(id);
    if (!id.startsWith('local_')) {
      await _db.addToSyncQueue(
        entityType: 'crop',
        entityId: id,
        localId: id,
        operation: 'delete',
        payload: {},
      );
    }
  }
}
