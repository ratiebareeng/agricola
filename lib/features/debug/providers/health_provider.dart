import 'package:agricola/features/debug/data/health_service.dart';
import 'package:agricola/features/debug/domain/providers/health_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for health status
final healthStatusProvider = StateNotifierProvider<HealthNotifier, HealthState>(
  (ref) {
    final healthService = ref.watch(healthServiceProvider);
    return HealthNotifier(healthService);
  },
);

class HealthNotifier extends StateNotifier<HealthState> {
  final HealthService _healthService;

  HealthNotifier(this._healthService) : super(const HealthState());

  Future<void> getHealth() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final healthStatus = await _healthService.getHealthStatus();
      state = state.copyWith(healthStatus: healthStatus, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await getHealth();
  }
}

class HealthState {
  final bool healthStatus;
  final bool isLoading;
  final String? error;

  const HealthState({
    this.healthStatus = false,
    this.isLoading = false,
    this.error,
  });

  HealthState copyWith({bool? healthStatus, bool? isLoading, String? error}) {
    return HealthState(
      healthStatus: healthStatus ?? this.healthStatus,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
