import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/providers/onboarding_provider.dart';
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

    final hasSeenOnboardingAsync = ref.read(hasSeenOnboardingProvider);
    final hasSeenOnboarding = hasSeenOnboardingAsync.value ?? false;

    final hasSeenProfileSetupAsync = ref.read(hasSeenProfileSetupProvider);
    final hasSeenProfileSetup = hasSeenProfileSetupAsync.value ?? false;

    // FIRST TIME USER FLOW
    // 1. Show welcome screen if not seen
    if (path == '/' && !hasSeenWelcome) {
      return null;
    }

    // 2. Show onboarding if welcome seen but onboarding not seen
    if (!hasSeenOnboarding) {
      if (path != '/onboarding') {
        return '/onboarding';
      }
      return null;
    }

    // AUTHENTICATED USER FLOW
    if (authState.isAuthenticated) {
      if (RouteGuardHelpers.isPublicRoute(path) && path != '/') {
        return '/home';
      }

      if (authState.needsProfileSetup && !hasSeenProfileSetup) {
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

      return null;
    }

    // UNAUTHENTICATED/ANONYMOUS USER FLOW
    // After onboarding, allow access to home
    if (hasSeenOnboarding) {
      if (path == '/' || path == '/onboarding') {
        return '/home';
      }

      return null;
    }

    return null;
  }
}
