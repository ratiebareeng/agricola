import 'package:agricola/core/providers/app_initialization_provider.dart';
import 'package:agricola/core/routing/route_guard_helpers.dart';
import 'package:agricola/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouteGuards {
  static String? redirect(WidgetRef ref, GoRouterState state) {
    final path = state.uri.path;

    // Check if initialization is complete
    final initState = ref.read(appInitializationStateProvider);

    // Show splash screen while initializing
    if (initState == null) {
      return path == '/splash' ? null : '/splash';
    }

    // Debug route check
    if (!RouteGuardHelpers.canAccessDebugRoute(path)) {
      return '/';
    }

    // Now we can safely use all the initialized data
    final hasSeenWelcome = initState.hasSeenWelcome;
    final hasSeenOnboarding = initState.hasSeenOnboarding;
    final authState = ref.read(unifiedAuthStateProvider);

    // FIRST TIME USER FLOW - Welcome screen
    if (!hasSeenWelcome) {
      return path == '/' ? null : '/';
    }

    // FIRST TIME USER FLOW - Onboarding
    if (!hasSeenOnboarding) {
      return path == '/onboarding' ? null : '/onboarding';
    }

    // AUTHENTICATED USER FLOW (includes users with incomplete profiles)
    if (authState.isAuthenticated || authState.needsProfileSetup) {
      // Allow users to access profile-setup anytime (not just on first login)
      // This enables returning users with incomplete profiles to complete it
      if (path == '/profile-setup') {
        return null;
      }

      // Redirect authenticated users from public routes (including splash) to home
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

    // ANONYMOUS USER FLOW - Redirect to home after onboarding
    if (path == '/' || path == '/onboarding') {
      return '/home';
    }

    return null;
  }
}
