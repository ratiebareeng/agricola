import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/features/auth/screens/registration_screen.dart';
import 'package:agricola/features/auth/screens/sign_in_screen.dart';
import 'package:agricola/features/auth/screens/sign_up_screen.dart';
import 'package:agricola/features/debug/screens/health_check_page.dart';
import 'package:agricola/features/home/screens/home_screen.dart';
import 'package:agricola/features/onboarding/screens/onboarding_screen.dart';
import 'package:agricola/features/onboarding/screens/welcome_screen.dart';
import 'package:agricola/features/profile_setup/screens/profile_setup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      builder: (context, state) {
        return const HealthCheckPage();
      },
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
