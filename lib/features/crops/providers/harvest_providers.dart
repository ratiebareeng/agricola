import 'package:agricola/core/database/daos/harvest_local_dao.dart';
import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/core/providers/connectivity_provider.dart';
import 'package:agricola/core/providers/database_provider.dart';
import 'package:agricola/core/providers/offline_settings_provider.dart';
import 'package:agricola/features/crops/data/harvest_api_service.dart';
import 'package:agricola/features/crops/data/harvest_offline_repository.dart';
import 'package:agricola/features/crops/models/harvest_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final harvestApiServiceProvider = Provider<HarvestApiService>((ref) {
  return HarvestApiService(ref.watch(httpClientProvider));
});

final harvestLocalDaoProvider = Provider<HarvestLocalDao>((ref) {
  return HarvestLocalDao(ref.watch(databaseProvider));
});

final harvestOfflineRepositoryProvider =
    Provider<HarvestOfflineRepository>((ref) {
  return HarvestOfflineRepository(
    apiService: ref.watch(harvestApiServiceProvider),
    localDao: ref.watch(harvestLocalDaoProvider),
    db: ref.watch(databaseProvider),
    isOnline: () => ref.read(isOnlineProvider),
    offlineEnabled: () => ref.read(offlineModeEnabledProvider),
  );
});

final harvestNotifierProvider =
    StateNotifierProviderFamily<HarvestNotifier, AsyncValue<List<HarvestModel>>,
        String>(
      (ref, cropId) {
        return HarvestNotifier(
            ref.watch(harvestOfflineRepositoryProvider), cropId);
      },
    );

class HarvestNotifier extends StateNotifier<AsyncValue<List<HarvestModel>>> {
  final HarvestOfflineRepository _repository;
  final String _cropId;

  HarvestNotifier(this._repository, this._cropId)
      : super(const AsyncValue.loading()) {
    loadHarvests();
  }

  Future<void> loadHarvests() async {
    state = const AsyncValue.loading();
    try {
      final harvests = await _repository.getHarvestsByCrop(_cropId);
      state = AsyncValue.data(harvests);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> addHarvest(HarvestModel harvest) async {
    try {
      final created = await _repository.createHarvest(harvest);
      final current = state.value ?? [];
      state = AsyncValue.data([created, ...current]);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteHarvest(String harvestId) async {
    try {
      await _repository.deleteHarvest(harvestId);
      final current = state.value ?? [];
      state = AsyncValue.data(
          current.where((h) => h.id != harvestId).toList());
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
