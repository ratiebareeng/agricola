import 'package:agricola/core/utils/error_utils.dart';
import 'package:agricola/core/providers/analytics_provider.dart';
import 'package:agricola/core/services/analytics_service.dart';
import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/features/loss_calculator/data/loss_calculator_api_service.dart';
import 'package:agricola/features/loss_calculator/models/loss_calculation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final lossCalculatorApiServiceProvider =
    Provider<LossCalculatorApiService>((ref) {
  return LossCalculatorApiService(ref.watch(httpClientProvider));
});

final lossCalculatorNotifierProvider = StateNotifierProvider<
    LossCalculatorNotifier, AsyncValue<List<LossCalculation>>>((ref) {
  return LossCalculatorNotifier(
    ref.watch(lossCalculatorApiServiceProvider),
    ref.watch(analyticsServiceProvider),
  );
});

class LossCalculatorNotifier
    extends StateNotifier<AsyncValue<List<LossCalculation>>> {
  final LossCalculatorApiService _apiService;
  final AnalyticsService _analytics;

  LossCalculatorNotifier(this._apiService, this._analytics)
      : super(const AsyncValue.loading()) {
    loadCalculations();
  }

  Future<void> loadCalculations() async {
    state = const AsyncValue.loading();
    try {
      final calculations = await _apiService.getCalculations();
      state = AsyncValue.data(calculations);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> saveCalculation(LossCalculation calculation) async {
    try {
      final saved = await _apiService.saveCalculation(calculation);
      state = AsyncValue.data([saved, ...state.value ?? []]);
      _analytics.logLossCalculated();
      return null;
    } catch (e) {
      return errorKeyFromException(e);
    }
  }

  Future<String?> deleteCalculation(String id) async {
    try {
      await _apiService.deleteCalculation(id);
      final current = state.value ?? [];
      state = AsyncValue.data(current.where((c) => c.id != id).toList());
      return null;
    } catch (e) {
      return errorKeyFromException(e);
    }
  }
}
