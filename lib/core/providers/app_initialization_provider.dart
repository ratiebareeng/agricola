import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// StateNotifier for managing SharedPreferences flags
class AppInitializationNotifier extends StateNotifier<AsyncValue<AppInitializationState>> {
  AppInitializationNotifier(this._ref) : super(const AsyncValue.loading()) {
    _initialize();
  }

  final Ref _ref;

  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authAsync = _ref.read(authStateProvider);

      final authUser = authAsync.maybeWhen(
        data: (user) => user,
        orElse: () => null,
      );

      state = AsyncValue.data(
        AppInitializationState(
          hasSeenWelcome: prefs.getBool('has_seen_welcome') ?? false,
          hasSeenOnboarding: prefs.getBool('has_seen_onboarding') ?? false,
          hasSeenProfileSetup: prefs.getBool('has_seen_profile_setup') ?? false,
          authUser: authUser,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update a specific flag synchronously (after it's been written to SharedPreferences)
  Future<void> updateFlag({
    bool? hasSeenWelcome,
    bool? hasSeenOnboarding,
    bool? hasSeenProfileSetup,
  }) async {
    state.whenData((currentState) {
      state = AsyncValue.data(
        AppInitializationState(
          hasSeenWelcome: hasSeenWelcome ?? currentState.hasSeenWelcome,
          hasSeenOnboarding: hasSeenOnboarding ?? currentState.hasSeenOnboarding,
          hasSeenProfileSetup: hasSeenProfileSetup ?? currentState.hasSeenProfileSetup,
          authUser: currentState.authUser,
        ),
      );
    });
  }

  /// Reload flags from SharedPreferences (for edge cases)
  Future<void> reload() async {
    await _initialize();
  }
}

/// Combined initialization provider that waits for both prefs and auth
final appInitializationProvider = StateNotifierProvider<AppInitializationNotifier, AsyncValue<AppInitializationState>>((ref) {
  return AppInitializationNotifier(ref);
});

/// Synchronous access to initialization state (only use after initialization is complete)
final appInitializationStateProvider = Provider<AppInitializationState?>((ref) {
  final initAsync = ref.watch(appInitializationProvider);
  return initAsync.maybeWhen(
    data: (state) => state,
    orElse: () => null,
  );
});

class AppInitializationState {
  final bool hasSeenWelcome;
  final bool hasSeenOnboarding;
  final bool hasSeenProfileSetup;
  final dynamic authUser;

  const AppInitializationState({
    required this.hasSeenWelcome,
    required this.hasSeenOnboarding,
    required this.hasSeenProfileSetup,
    required this.authUser,
  });

  bool get isInitialized => true;
}
