import 'dart:developer' as developer;

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

    // 1. Show splash screen while initializing
    if (initAsync is! AsyncData<AppInitializationState>) {
      developer.log('🔄 REDIRECT: $path -> /splash (initializing)', name: 'RouteGuards');
      return path == '/splash' ? null : '/splash';
    }

    final initState = initAsync.value;
    final authState = ref.read(unifiedAuthStateProvider);

    // Extract state
    final hasSeenWelcome = initState.hasSeenWelcome;
    final hasSeenOnboarding = initState.hasSeenOnboarding;
    final isAuthenticated = authState.isAuthenticated;
    final isAnonymous = authState.user?.isAnonymous ?? false;

    developer.log(
      '🧭 ROUTE GUARD CHECK\n'
      '  Current path: $path\n'
      '  hasSeenWelcome: $hasSeenWelcome\n'
      '  hasSeenOnboarding: $hasSeenOnboarding\n'
      '  isAuthenticated: $isAuthenticated\n'
      '  isAnonymous: $isAnonymous\n'
      '  authState: ${authState.toString()}',
      name: 'RouteGuards',
    );

    // Debug route check
    if (!RouteGuardHelpers.canAccessDebugRoute(path)) {
      developer.log('🔄 REDIRECT: $path -> / (debug route blocked)', name: 'RouteGuards');
      return '/';
    }

    // 2. First time user - needs language selection
    if (!hasSeenWelcome && path != '/') {
      developer.log('🔄 REDIRECT: $path -> / (first time user, need welcome)', name: 'RouteGuards');
      return '/';
    }

    // 3. Needs onboarding
    if (hasSeenWelcome && !hasSeenOnboarding && path != '/onboarding') {
      developer.log('🔄 REDIRECT: $path -> /onboarding (seen welcome, need onboarding)', name: 'RouteGuards');
      return '/onboarding';
    }

    // 4. Completed onboarding but not authenticated/anonymous - needs registration
    if (hasSeenOnboarding && !isAuthenticated && !isAnonymous) {
      // Allow auth routes and profile setup (for post-signup flow)
      if (path == '/register' || path == '/sign-up' || path == '/sign-in' || path == '/profile-setup') {
        developer.log('✅ ALLOW: $path (auth/setup route)', name: 'RouteGuards');
        return null;
      }

      // Redirect everything else to register
      developer.log('🔄 REDIRECT: $path -> /register (seen onboarding, needs registration)', name: 'RouteGuards');
      return '/register';
    }

    // 5. Authenticated or anonymous users
    if (isAuthenticated || isAnonymous) {
      // Redirect from auth routes to profile setup or home
      if (path == '/register' || path == '/sign-up' || path == '/sign-in') {
        // If authenticated (not anonymous) and hasn't completed profile setup, go to profile setup
        if (isAuthenticated && !isAnonymous) {
          developer.log('🔄 REDIRECT: $path -> /profile-setup (authenticated user on auth screen)', name: 'RouteGuards');
          return '/profile-setup';
        }
        // Anonymous users can access auth routes (for account upgrade)
        developer.log('✅ ALLOW: $path (anonymous user can upgrade account)', name: 'RouteGuards');
        return null;
      }

      // Allow profile setup
      if (path == '/profile-setup') {
        developer.log('✅ ALLOW: $path (profile setup page)', name: 'RouteGuards');
        return null;
      }

      // Redirect intro screens to home
      if (path == '/splash' || path == '/' || path == '/onboarding') {
        developer.log('🔄 REDIRECT: $path -> /home (authenticated/anonymous user on intro screen)', name: 'RouteGuards');
        return '/home';
      }

      // Allow all other routes
      developer.log('✅ ALLOW: $path (authenticated/anonymous user)', name: 'RouteGuards');
      return null;
    }

    // 6. Default allow (should not reach here)
    developer.log('✅ ALLOW: $path (default)', name: 'RouteGuards');
    return null;
  }
}
