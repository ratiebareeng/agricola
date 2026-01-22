import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/routing/route_guard_helpers.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/auth/providers/auth_state_provider.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouteGuards {
  static String? redirect(WidgetRef ref, GoRouterState state) {
    final authState = ref.read(unifiedAuthStateProvider);
    final path = state.uri.path;

    if (!RouteGuardHelpers.canAccessDebugRoute(path)) {
      return '/';
    }

    final hasSeenWelcomeAsync = ref.read(hasSeenWelcomeProvider);
    final hasSeenWelcome = hasSeenWelcomeAsync.value ?? false;

    if (path == '/' && hasSeenWelcome && !authState.isAuthenticated) {
      return '/onboarding';
    }

    final isPublicRoute = RouteGuardHelpers.isPublicRoute(path);

    if (authState.isAuthenticated) {
      if (isPublicRoute && path != '/') {
        return '/home';
      }
      return null;
    }

    if (authState.needsProfileSetup) {
      if (path != '/profile-setup') {
        final user = authState.user;
        String userTypeParam = 'farmer';
        if (user?.userType == UserType.merchant) {
          userTypeParam = user?.merchantType == MerchantType.agriShop
              ? 'agriShop'
              : 'supermarketVendor';
        }
        return '/profile-setup?type=$userTypeParam';
      }
      return null;
    }

    if (!isPublicRoute && path != '/profile-setup') {
      return '/';
    }

    return null;
  }
}
