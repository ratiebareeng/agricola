import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/providers/onboarding_provider.dart';
import 'package:agricola/core/routing/route_guards.dart';
import 'package:agricola/features/auth/screens/registration_screen.dart';
import 'package:agricola/features/auth/screens/sign_in_screen.dart';
import 'package:agricola/features/auth/screens/sign_up_screen.dart';
import 'package:agricola/features/debug/screens/health_check_page.dart';
import 'package:agricola/features/home/screens/home_screen.dart';
import 'package:agricola/features/onboarding/screens/onboarding_screen.dart';
import 'package:agricola/features/onboarding/screens/welcome_screen.dart';
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
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) => RouteGuards.redirect(ref, state),
    routes: [
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

  RouterNotifier(this._ref) {
    _ref.listen(hasSeenWelcomeProvider, (_, __) => notifyListeners());
    _ref.listen(hasSeenOnboardingProvider, (_, __) => notifyListeners());
    _ref.listen(hasSeenProfileSetupProvider, (_, __) => notifyListeners());
  }
}
