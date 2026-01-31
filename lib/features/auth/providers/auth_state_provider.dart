import 'package:agricola/domain/auth/models/user_model.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Route protection helpers
final requiresAuthProvider = Provider.family<bool, String>((ref, route) {
  final authState = ref.watch(unifiedAuthStateProvider);

  const protectedRoutes = {
    '/home',
    '/profile',
    '/marketplace',
    '/inventory',
    '/crops',
  };

  if (!protectedRoutes.contains(route)) {
    return false;
  }

  return !authState.isAuthenticated;
});

final requiresProfileSetupProvider = Provider.family<bool, String>((
  ref,
  route,
) {
  final authState = ref.watch(unifiedAuthStateProvider);

  // Routes that require completed profile
  const profileDependentRoutes = {
    '/home',
    '/marketplace',
    '/inventory',
    '/crops',
  };

  if (!profileDependentRoutes.contains(route)) {
    return false;
  }

  return authState.isAuthenticated && authState.needsProfileSetup;
});

final unifiedAuthStateProvider = Provider<AuthState>((ref) {
  final authAsync = ref.watch(authStateProvider);

  return authAsync.when(
    data: (user) {
      if (user == null) {
        return const AuthState(status: AuthStatus.unauthenticated);
      }

      if (!user.isProfileComplete) {
        return AuthState(status: AuthStatus.profileIncomplete, user: user);
      }

      return AuthState(status: AuthStatus.authenticated, user: user);
    },
    loading: () => const AuthState(status: AuthStatus.loading),
    error: (error, _) =>
        AuthState(status: AuthStatus.unauthenticated, error: error.toString()),
  );
});

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({required this.status, this.user, this.error});

  bool get hasError => error != null;

  // User is authenticated if they have an account, regardless of profile completion
  bool get isAuthenticated =>
      status == AuthStatus.authenticated || status == AuthStatus.profileIncomplete;
  bool get isLoading => status == AuthStatus.loading;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get needsProfileSetup => status == AuthStatus.profileIncomplete;
  AuthState copyWith({AuthStatus? status, UserModel? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

/// Global auth state for the entire application
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  profileIncomplete,
}
