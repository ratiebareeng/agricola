import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/features/marketplace/data/crop_availability_api_service.dart';
import 'package:agricola/features/marketplace/models/crop_availability_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cropAvailabilityApiServiceProvider =
    Provider<CropAvailabilityApiService>((ref) {
  return CropAvailabilityApiService(ref.watch(httpClientProvider));
});

final cropAvailabilityProvider = StateNotifierProvider<
    CropAvailabilityNotifier, AsyncValue<CropAvailabilityData>>((ref) {
  return CropAvailabilityNotifier(ref.watch(cropAvailabilityApiServiceProvider));
});

class CropAvailabilityNotifier
    extends StateNotifier<AsyncValue<CropAvailabilityData>> {
  final CropAvailabilityApiService _service;
  String? _activeCropType;

  CropAvailabilityNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load({String? cropType, int weeks = 8}) async {
    _activeCropType = cropType;
    state = const AsyncValue.loading();
    try {
      final data = await _service.getCropAvailability(
        cropType: cropType,
        weeks: weeks,
      );
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => load(cropType: _activeCropType);
}
