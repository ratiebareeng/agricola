import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider that loads SharedPreferences flags
final _sharedPrefsInitProvider = FutureProvider<_PrefsData>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return _PrefsData(
    hasSeenWelcome: prefs.getBool('has_seen_welcome') ?? false,
    hasSeenOnboarding: prefs.getBool('has_seen_onboarding') ?? false,
    hasSeenProfileSetup: prefs.getBool('has_seen_profile_setup') ?? false,
  );
});

/// Combined initialization provider that waits for both prefs and auth
final appInitializationProvider = Provider<AsyncValue<AppInitializationState>>((ref) {
  final prefsAsync = ref.watch(_sharedPrefsInitProvider);
  final authAsync = ref.watch(authStateProvider);

  // Both must be loaded before we return data
  if (prefsAsync is AsyncLoading || authAsync is AsyncLoading) {
    return const AsyncValue.loading();
  }

  if (prefsAsync is AsyncError) {
    return AsyncValue.error(prefsAsync.error!, prefsAsync.stackTrace!);
  }

  if (authAsync is AsyncError) {
    return AsyncValue.error(authAsync.error!, authAsync.stackTrace!);
  }

  // Both are loaded successfully
  final prefsData = prefsAsync.value!;
  final authUser = authAsync.value;

  return AsyncValue.data(
    AppInitializationState(
      hasSeenWelcome: prefsData.hasSeenWelcome,
      hasSeenOnboarding: prefsData.hasSeenOnboarding,
      hasSeenProfileSetup: prefsData.hasSeenProfileSetup,
      authUser: authUser,
    ),
  );
});

/// Synchronous access to initialization state (only use after initialization is complete)
final appInitializationStateProvider = Provider<AppInitializationState?>((ref) {
  final initAsync = ref.watch(appInitializationProvider);
  return initAsync.maybeWhen(
    data: (state) => state,
    orElse: () => null,
  );
});

class _PrefsData {
  final bool hasSeenWelcome;
  final bool hasSeenOnboarding;
  final bool hasSeenProfileSetup;

  _PrefsData({
    required this.hasSeenWelcome,
    required this.hasSeenOnboarding,
    required this.hasSeenProfileSetup,
  });
}

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
