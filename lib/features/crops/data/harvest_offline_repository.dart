import 'package:agricola/core/database/app_database.dart';
import 'package:agricola/core/database/daos/harvest_local_dao.dart';
import 'package:agricola/features/crops/data/harvest_api_service.dart';
import 'package:agricola/features/crops/models/harvest_model.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class HarvestOfflineRepository {
  final HarvestApiService _apiService;
  final HarvestLocalDao _localDao;
  final AppDatabase _db;
  final bool Function() _isOnline;
  final bool Function() _offlineEnabled;

  HarvestOfflineRepository({
    required HarvestApiService apiService,
    required HarvestLocalDao localDao,
    required AppDatabase db,
    required bool Function() isOnline,
    required bool Function() offlineEnabled,
  })  : _apiService = apiService,
        _localDao = localDao,
        _db = db,
        _isOnline = isOnline,
        _offlineEnabled = offlineEnabled;

  Future<List<HarvestModel>> getHarvestsByCrop(String cropId) async {
    if (!_offlineEnabled()) return _apiService.getHarvestsByCrop(cropId);

    if (_isOnline()) {
      try {
        final harvests = await _apiService.getHarvestsByCrop(cropId);
        await _localDao.cacheForCrop(cropId, harvests);
        return harvests;
      } catch (_) {
        return _localDao.getByCropId(cropId);
      }
    }
    return _localDao.getByCropId(cropId);
  }

  Future<HarvestModel> createHarvest(HarvestModel harvest) async {
    if (!_offlineEnabled() || _isOnline()) {
      final created = await _apiService.createHarvest(harvest);
      if (_offlineEnabled()) await _localDao.upsertOne(created);
      return created;
    }

    final localId = 'local_${_uuid.v4()}';
    final offlineHarvest = HarvestModel(
      id: localId,
      cropId: harvest.cropId,
      harvestDate: harvest.harvestDate,
      actualYield: harvest.actualYield,
      yieldUnit: harvest.yieldUnit,
      quality: harvest.quality,
      lossAmount: harvest.lossAmount,
      lossReason: harvest.lossReason,
      storageLocation: harvest.storageLocation,
      notes: harvest.notes,
      createdAt: harvest.createdAt,
    );
    await _localDao.upsertOne(offlineHarvest, isSynced: false, localId: localId);
    await _db.addToSyncQueue(
      entityType: 'harvest',
      localId: localId,
      operation: 'create',
      payload: harvest.toJson(),
    );
    return offlineHarvest;
  }

  Future<void> deleteHarvest(String harvestId) async {
    if (!_offlineEnabled() || _isOnline()) {
      await _apiService.deleteHarvest(harvestId);
      if (_offlineEnabled()) await _localDao.deleteOne(harvestId);
      return;
    }

    await _localDao.deleteOne(harvestId);
    if (!harvestId.startsWith('local_')) {
      await _db.addToSyncQueue(
        entityType: 'harvest',
        entityId: harvestId,
        localId: harvestId,
        operation: 'delete',
        payload: {},
      );
    }
  }
}
