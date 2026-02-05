import 'dart:async';

import 'package:agricola/core/providers/app_initialization_provider.dart';
import 'package:agricola/core/routing/route_guards.dart';
import 'package:agricola/core/screens/splash_screen.dart';
import 'package:agricola/features/auth/providers/auth_state_provider.dart';
import 'package:agricola/features/auth/screens/registration_screen.dart';
import 'package:agricola/features/auth/screens/sign_in_screen.dart';
import 'package:agricola/features/auth/screens/sign_up_screen.dart';
import 'package:agricola/features/debug/screens/health_check_page.dart';
import 'package:agricola/features/home/screens/home_screen.dart';
import 'package:agricola/features/onboarding/screens/onboarding_screen.dart';
import 'package:agricola/features/onboarding/screens/welcome_screen.dart';
import 'package:agricola/features/profile_setup/screens/profile_setup_complete_screen.dart';
import 'package:agricola/features/profile_setup/screens/profile_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

GoRouter createRouter(WidgetRef ref) {
  final notifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) => RouteGuards.redirect(ref, state),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) =>
            SignUpScreen(userType: state.uri.queryParameters['type']),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => ProfileSetupScreen(
          initialUserType: state.uri.queryParameters['type'],
        ),
      ),
      GoRoute(
        path: '/profile-setup-complete',
        builder: (context, state) {
          final profileData = state.extra as Map<String, dynamic>? ?? {};
          return ProfileSetupCompleteScreen(profileData: profileData);
        },
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/debug/health-check',
        builder: (context, state) => const HealthCheckPage(),
      ),
    ],
  );
}

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  Timer? _debounceTimer;

  RouterNotifier(this._ref) {
    // Listen to both initialization and auth state changes
    // This ensures the router re-evaluates route guards when either changes
    _ref.listen(appInitializationProvider, (_, __) {
      _notifyWithDebounce();
    });
    _ref.listen(unifiedAuthStateProvider, (previous, next) {
      _notifyWithDebounce();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Debounce router notifications to prevent rapid route re-evaluations
  /// that can cause screen flickering during auth state transitions
  void _notifyWithDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      notifyListeners();
    });
  }
}
