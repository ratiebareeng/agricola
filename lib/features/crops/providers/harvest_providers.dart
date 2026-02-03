import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/features/crops/data/harvest_api_service.dart';
import 'package:agricola/features/crops/models/harvest_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final harvestApiServiceProvider = Provider<HarvestApiService>((ref) {
  return HarvestApiService(ref.watch(httpClientProvider));
});

final harvestNotifierProvider =
    StateNotifierProviderFamily<HarvestNotifier, AsyncValue<List<HarvestModel>>,
        String>(
      (ref, cropId) {
        return HarvestNotifier(ref.watch(harvestApiServiceProvider), cropId);
      },
    );

class HarvestNotifier extends StateNotifier<AsyncValue<List<HarvestModel>>> {
  final HarvestApiService _service;
  final String _cropId;

  HarvestNotifier(this._service, this._cropId) : super(const AsyncValue.loading()) {
    loadHarvests();
  }

  /// Fetch harvests for this crop from the backend.
  Future<void> loadHarvests() async {
    state = const AsyncValue.loading();
    try {
      final harvests = await _service.getHarvestsByCrop(_cropId);
      state = AsyncValue.data(harvests);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add a harvest. Returns null on success, error message on failure.
  Future<String?> addHarvest(HarvestModel harvest) async {
    try {
      final created = await _service.createHarvest(harvest);
      final current = state.value ?? [];
      state = AsyncValue.data([created, ...current]);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Delete a harvest by ID. Returns null on success, error message on failure.
  Future<String?> deleteHarvest(String harvestId) async {
    try {
      await _service.deleteHarvest(harvestId);
      final current = state.value ?? [];
      state = AsyncValue.data(current.where((h) => h.id != harvestId).toList());
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
