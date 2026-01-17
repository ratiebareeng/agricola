import 'package:agricola/core/routing/route_guard_helpers.dart';
import 'package:agricola/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouteGuards {
  static String? redirect(WidgetRef ref, GoRouterState state) {
    final authState = ref.read(unifiedAuthStateProvider);
    final path = state.uri.path;

    if (!RouteGuardHelpers.canAccessDebugRoute(path)) {
      return '/';
    }

    final isPublicRoute = RouteGuardHelpers.isPublicRoute(path);

    if (authState.isAuthenticated) {
      if (authState.needsProfileSetup) {
        if (path != '/profile-setup') {
          final userType = state.uri.queryParameters['type'] ?? 'farmer';
          return '/profile-setup?type=$userType';
        }
        return null;
      }

      if (isPublicRoute) {
        return '/home';
      }
      return null;
    }

    if (!isPublicRoute && path != '/profile-setup') {
      return '/';
    }

    return null;
  }
}
