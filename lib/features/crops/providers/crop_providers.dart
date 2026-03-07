import 'package:agricola/core/database/daos/crop_local_dao.dart';
import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/core/providers/connectivity_provider.dart';
import 'package:agricola/core/providers/database_provider.dart';
import 'package:agricola/core/providers/offline_settings_provider.dart';
import 'package:agricola/features/crops/data/crop_api_service.dart';
import 'package:agricola/features/crops/data/crop_offline_repository.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cropApiServiceProvider = Provider<CropApiService>((ref) {
  return CropApiService(ref.watch(httpClientProvider));
});

final cropLocalDaoProvider = Provider<CropLocalDao>((ref) {
  return CropLocalDao(ref.watch(databaseProvider));
});

final cropOfflineRepositoryProvider = Provider<CropOfflineRepository>((ref) {
  return CropOfflineRepository(
    apiService: ref.watch(cropApiServiceProvider),
    localDao: ref.watch(cropLocalDaoProvider),
    db: ref.watch(databaseProvider),
    isOnline: () => ref.read(isOnlineProvider),
    offlineEnabled: () => ref.read(offlineModeEnabledProvider),
  );
});

final cropNotifierProvider =
    StateNotifierProvider<CropNotifier, AsyncValue<List<CropModel>>>((ref) {
      return CropNotifier(ref.watch(cropOfflineRepositoryProvider));
    });

class CropNotifier extends StateNotifier<AsyncValue<List<CropModel>>> {
  final CropOfflineRepository _repository;

  CropNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCrops();
  }

  Future<void> loadCrops() async {
    state = const AsyncValue.loading();
    try {
      final crops = await _repository.getUserCrops();
      state = AsyncValue.data(crops);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> addCrop(CropModel crop) async {
    try {
      final created = await _repository.createCrop(crop);
      final current = state.value ?? [];
      state = AsyncValue.data([created, ...current]);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateCrop(CropModel crop) async {
    try {
      final updated = await _repository.updateCrop(crop.id!, crop);
      final current = state.value ?? [];
      state = AsyncValue.data(
        current.map((c) => c.id == crop.id ? updated : c).toList(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteCrop(String id) async {
    try {
      await _repository.deleteCrop(id);
      final current = state.value ?? [];
      state = AsyncValue.data(current.where((c) => c.id != id).toList());
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
