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
    final hasSeenOnboardingAsync = ref.read(hasSeenOnboardingProvider);
    final hasSeenProfileSetupAsync = ref.read(hasSeenProfileSetupProvider);

    final hasSeenWelcome = hasSeenWelcomeAsync.valueOrNull ?? false;
    final hasSeenOnboarding = hasSeenOnboardingAsync.valueOrNull ?? false;
    final hasSeenProfileSetup = hasSeenProfileSetupAsync.valueOrNull ?? false;

    // FIRST TIME USER FLOW - Welcome screen
    if (!hasSeenWelcome) {
      return path == '/' ? null : '/';
    }

    // FIRST TIME USER FLOW - Onboarding
    if (!hasSeenOnboarding) {
      return path == '/onboarding' ? null : '/onboarding';
    }

    // AUTHENTICATED USER FLOW
    if (authState.isAuthenticated) {
      // Check profile setup requirement
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

      // Redirect authenticated users from public routes to home
      if (path == '/' ||
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
