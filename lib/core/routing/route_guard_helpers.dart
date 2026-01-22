import 'package:flutter/foundation.dart';

class RouteGuardHelpers {
  static const publicRoutes = {
    '/',
    '/onboarding',
    '/register',
    '/sign-up',
    '/sign-in',
    '/home',
  };

  static const protectedRoutes = {
    '/home',
    '/profile',
    '/marketplace',
    '/inventory',
    '/crops',
  };

  static const profileDependentRoutes = {
    '/home',
    '/marketplace',
    '/inventory',
    '/crops',
  };

  static bool get isDebugBuild => kDebugMode || kProfileMode;

  const RouteGuardHelpers._();

  static bool canAccessDebugRoute(String path) {
    if (!isDebugRoute(path)) return true;
    return isDebugBuild;
  }

  static bool isDebugRoute(String path) => path.startsWith('/debug/');

  static bool isProtectedRoute(String path) => protectedRoutes.contains(path);

  static bool isPublicRoute(String path) => publicRoutes.contains(path);

  static bool requiresCompleteProfile(String path) =>
      profileDependentRoutes.contains(path);
}
