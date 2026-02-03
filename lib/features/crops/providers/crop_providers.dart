import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/features/crops/data/crop_api_service.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cropApiServiceProvider = Provider<CropApiService>((ref) {
  return CropApiService(ref.watch(httpClientProvider));
});

final cropNotifierProvider =
    StateNotifierProvider<CropNotifier, AsyncValue<List<CropModel>>>((ref) {
      return CropNotifier(ref.watch(cropApiServiceProvider));
    });

class CropNotifier extends StateNotifier<AsyncValue<List<CropModel>>> {
  final CropApiService _service;

  CropNotifier(this._service) : super(const AsyncValue.loading()) {
    loadCrops();
  }

  /// Fetch crops from the backend. Sets state to error if the request fails.
  Future<void> loadCrops() async {
    state = const AsyncValue.loading();
    try {
      final crops = await _service.getUserCrops();
      state = AsyncValue.data(crops);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add a crop. Returns null on success, error message on failure.
  /// Does not replace the existing list on error.
  Future<String?> addCrop(CropModel crop) async {
    try {
      final created = await _service.createCrop(crop);
      final current = state.value ?? [];
      state = AsyncValue.data([created, ...current]);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Update a crop. Returns null on success, error message on failure.
  Future<String?> updateCrop(CropModel crop) async {
    try {
      final updated = await _service.updateCrop(crop.id!, crop);
      final current = state.value ?? [];
      state = AsyncValue.data(
        current.map((c) => c.id == crop.id ? updated : c).toList(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Delete a crop. Returns null on success, error message on failure.
  Future<String?> deleteCrop(String id) async {
    try {
      await _service.deleteCrop(id);
      final current = state.value ?? [];
      state = AsyncValue.data(current.where((c) => c.id != id).toList());
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
