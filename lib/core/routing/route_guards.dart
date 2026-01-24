import 'package:agricola/core/providers/app_initialization_provider.dart';
import 'package:agricola/core/routing/route_guard_helpers.dart';
import 'package:agricola/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouteGuards {
  static String? redirect(WidgetRef ref, GoRouterState state) {
    final path = state.uri.path;

    // Read initialization state directly (not the synchronous wrapper)
    final initAsync = ref.read(appInitializationProvider);

    // Show splash screen while initializing
    if (initAsync is! AsyncData<AppInitializationState>) {
      return path == '/splash' ? null : '/splash';
    }

    final initState = initAsync.value;
    final authState = ref.read(unifiedAuthStateProvider);

    // Debug route check
    if (!RouteGuardHelpers.canAccessDebugRoute(path)) {
      return '/';
    }

    // Now we can safely use all the initialized data
    final hasSeenWelcome = initState.hasSeenWelcome;
    final hasSeenOnboarding = initState.hasSeenOnboarding;

    // FIRST TIME USER FLOW - Welcome screen
    if (!hasSeenWelcome && path != '/') {
      return '/';
    }

    // FIRST TIME USER FLOW - Onboarding
    if (hasSeenWelcome && !hasSeenOnboarding && path != '/onboarding') {
      return '/onboarding';
    }

    // AUTHENTICATED USER FLOW
    if (authState.isAuthenticated || authState.needsProfileSetup) {
      if (path == '/profile-setup') {
        return null;
      }

      if (path == '/splash' ||
          path == '/' ||
          path == '/onboarding' ||
          path == '/register' ||
          path == '/sign-in' ||
          path == '/sign-up') {
        return '/home';
      }

      return null;
    }

    // ANONYMOUS USER FLOW - After completing onboarding, go to home
    if (hasSeenOnboarding) {
      if (path == '/splash' || path == '/') {
        return '/home';
      }
      return null;
    }

    return null;
  }
}
