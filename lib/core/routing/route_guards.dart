import 'package:agricola/core/providers/app_initialization_provider.dart';
import 'package:agricola/core/routing/navigation_helpers.dart';
import 'package:agricola/core/routing/route_guard_helpers.dart';
import 'package:agricola/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouteGuards {
  static String? redirect(WidgetRef ref, GoRouterState state) {
    final path = state.uri.path;

    // Read initialization state directly (not the synchronous wrapper)
    final initAsync = ref.read(appInitializationProvider);

    // 1. Show splash screen while initializing
    if (initAsync is! AsyncData<AppInitializationState>) {
      return path == '/splash' ? null : '/splash';
    }

    final initState = initAsync.value;
    final authState = ref.read(unifiedAuthStateProvider);

    // 2. Show splash screen while auth state is loading
    // This prevents the brief flash of registration screen while Firebase checks auth
    if (authState.isLoading) {
      return path == '/splash' ? null : '/splash';
    }

    // Extract state
    final hasSeenWelcome = initState.hasSeenWelcome;
    final hasSeenOnboarding = initState.hasSeenOnboarding;
    final isAuthenticated = authState.isAuthenticated;
    final isAnonymous = authState.user?.isAnonymous ?? false;

    // Debug route check
    if (!RouteGuardHelpers.canAccessDebugRoute(path)) {
      return '/';
    }

    // 3. First time user - needs language selection
    if (!hasSeenWelcome && path != '/') {
      return '/';
    }

    // 4. Needs onboarding
    if (hasSeenWelcome && !hasSeenOnboarding && path != '/onboarding') {
      return '/onboarding';
    }

    // 5. Completed onboarding but not authenticated/anonymous - needs registration
    if (hasSeenOnboarding && !isAuthenticated && !isAnonymous) {
      // Allow auth routes and profile setup (for post-signup flow)
      if (path == '/register' ||
          path == '/sign-up' ||
          path == '/sign-in' ||
          path == '/profile-setup') {
        return null;
      }

      // Keep user on splash if coming from splash (prevents brief registration flash)
      if (path == '/splash') {
        return null;
      }

      // Redirect everything else to sign-in (more natural default than register)
      return '/sign-in';
    }

    // 6. Authenticated or anonymous users
    if (isAuthenticated || isAnonymous) {
      final user = authState.user;

      // Redirect from auth routes based on profile completion
      if (path == '/register' || path == '/sign-up' || path == '/sign-in') {
        if (isAuthenticated && !isAnonymous) {
          // Determine destination based on profile completion
          final destination = NavigationHelpers.getPostAuthDestination(user);
          return destination;
        }
        // Anonymous users can access auth routes (for account upgrade)
        return null;
      }

      // If profile is incomplete and user hasn't skipped, redirect to profile setup
      if (isAuthenticated &&
          !isAnonymous &&
          user != null &&
          !user.isProfileComplete &&
          !user.hasSkippedProfileSetup) {
        if (path != '/profile-setup' && path != '/profile-setup-complete') {
          return '/profile-setup';
        }
      }

      // Allow profile setup routes
      if (path == '/profile-setup' || path == '/profile-setup-complete') {
        return null;
      }

      // Redirect intro screens to appropriate destination
      if (path == '/splash' || path == '/' || path == '/onboarding') {
        final destination = NavigationHelpers.getPostAuthDestination(user);
        return destination;
      }

      // Allow all other routes
      return null;
    }

    // 7. Default allow (should not reach here)
    return null;
  }
}
