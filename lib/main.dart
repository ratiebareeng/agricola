import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/features/auth/screens/registration_screen.dart';
import 'package:agricola/features/auth/screens/sign_in_screen.dart';
import 'package:agricola/features/auth/screens/sign_up_screen.dart';
import 'package:agricola/features/onboarding/screens/onboarding_screen.dart';
import 'package:agricola/features/onboarding/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const ProviderScope(child: AgricolaApp()));
}

final _router = GoRouter(
  initialLocation: '/',
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
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
  ],
);

class AgricolaApp extends StatelessWidget {
  const AgricolaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Agricola',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
