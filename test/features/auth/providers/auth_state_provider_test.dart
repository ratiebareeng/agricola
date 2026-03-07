import 'package:agricola/domain/auth/models/user_model.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/auth/providers/auth_state_provider.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthState', () {
    test('isAuthenticated is true for authenticated status', () {
      const state = AuthState(status: AuthStatus.authenticated);
      expect(state.isAuthenticated, true);
    });

    test('isAuthenticated is true for profileIncomplete status', () {
      const state = AuthState(status: AuthStatus.profileIncomplete);
      expect(state.isAuthenticated, true);
    });

    test('isUnauthenticated is true for unauthenticated status', () {
      const state = AuthState(status: AuthStatus.unauthenticated);
      expect(state.isUnauthenticated, true);
      expect(state.isAuthenticated, false);
    });

    test('isLoading is true for loading status', () {
      const state = AuthState(status: AuthStatus.loading);
      expect(state.isLoading, true);
      expect(state.isAuthenticated, false);
    });

    test('needsProfileSetup is true for profileIncomplete status', () {
      const state = AuthState(status: AuthStatus.profileIncomplete);
      expect(state.needsProfileSetup, true);
    });

    test('hasError returns true when error is set', () {
      const state = AuthState(
        status: AuthStatus.unauthenticated,
        error: 'Something went wrong',
      );
      expect(state.hasError, true);
    });

    test('hasError returns false when error is null', () {
      const state = AuthState(status: AuthStatus.authenticated);
      expect(state.hasError, false);
    });

    test('copyWith updates specified fields', () {
      const original = AuthState(status: AuthStatus.loading);
      final copy = original.copyWith(
        status: AuthStatus.authenticated,
        error: 'test error',
      );

      expect(copy.status, AuthStatus.authenticated);
      expect(copy.error, 'test error');
    });

    test('copyWith preserves unspecified fields', () {
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.farmer,
      );
      final original = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
      final copy = original.copyWith(error: 'test');

      expect(copy.user, user);
      expect(copy.status, AuthStatus.authenticated);
    });
  });

  group('unifiedAuthStateProvider', () {
    late ProviderContainer container;

    tearDown(() => container.dispose());

    test('maps data(null) to unauthenticated', () async {
      container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(null),
          ),
        ],
      );

      // Read to trigger the stream subscription
      container.read(authStateProvider);

      // Let the stream emit
      await Future<void>.delayed(Duration.zero);

      final authState = container.read(unifiedAuthStateProvider);
      expect(authState.isUnauthenticated, true);
    });

    test('maps data(user with complete profile) to authenticated', () async {
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.farmer,
        isProfileComplete: true,
      );

      container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(user),
          ),
        ],
      );

      container.read(authStateProvider);
      await Future<void>.delayed(Duration.zero);

      final authState = container.read(unifiedAuthStateProvider);
      expect(authState.status, AuthStatus.authenticated);
      expect(authState.user, user);
    });

    test('maps data(user with incomplete profile) to profileIncomplete',
        () async {
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.farmer,
        isProfileComplete: false,
      );

      container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(user),
          ),
        ],
      );

      container.read(authStateProvider);
      await Future<void>.delayed(Duration.zero);

      final authState = container.read(unifiedAuthStateProvider);
      expect(authState.status, AuthStatus.profileIncomplete);
      expect(authState.needsProfileSetup, true);
    });

    test('maps loading to loading', () {
      container = ProviderContainer(
        overrides: [
          // A stream that never emits stays in loading state
          authStateProvider.overrideWith(
            (ref) => const Stream<UserModel?>.empty(),
          ),
        ],
      );

      // Read but don't await — stream never emits, so stays loading
      container.read(authStateProvider);

      final authState = container.read(unifiedAuthStateProvider);
      expect(authState.isLoading, true);
    });

    test('maps error to unauthenticated with error', () async {
      container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream<UserModel?>.error('Auth error'),
          ),
        ],
      );

      container.read(authStateProvider);
      await Future<void>.delayed(Duration.zero);

      final authState = container.read(unifiedAuthStateProvider);
      expect(authState.isUnauthenticated, true);
      expect(authState.error, 'Auth error');
    });
  });

  group('requiresAuthProvider', () {
    late ProviderContainer container;

    tearDown(() => container.dispose());

    test('returns true for protected routes when unauthenticated', () {
      container = ProviderContainer(
        overrides: [
          unifiedAuthStateProvider.overrideWith(
            (ref) => const AuthState(status: AuthStatus.unauthenticated),
          ),
        ],
      );

      expect(container.read(requiresAuthProvider('/home')), true);
      expect(container.read(requiresAuthProvider('/profile')), true);
      expect(container.read(requiresAuthProvider('/marketplace')), true);
      expect(container.read(requiresAuthProvider('/inventory')), true);
      expect(container.read(requiresAuthProvider('/crops')), true);
    });

    test('returns false for unprotected routes', () {
      container = ProviderContainer(
        overrides: [
          unifiedAuthStateProvider.overrideWith(
            (ref) => const AuthState(status: AuthStatus.unauthenticated),
          ),
        ],
      );

      expect(container.read(requiresAuthProvider('/welcome')), false);
      expect(container.read(requiresAuthProvider('/sign-in')), false);
    });

    test('returns false when authenticated', () {
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.farmer,
        isProfileComplete: true,
      );

      container = ProviderContainer(
        overrides: [
          unifiedAuthStateProvider.overrideWith(
            (ref) => AuthState(status: AuthStatus.authenticated, user: user),
          ),
        ],
      );

      expect(container.read(requiresAuthProvider('/home')), false);
    });
  });

  group('requiresProfileSetupProvider', () {
    late ProviderContainer container;

    tearDown(() => container.dispose());

    test(
        'returns true for profile-dependent routes when profileIncomplete',
        () {
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.farmer,
        isProfileComplete: false,
      );

      container = ProviderContainer(
        overrides: [
          unifiedAuthStateProvider.overrideWith(
            (ref) =>
                AuthState(status: AuthStatus.profileIncomplete, user: user),
          ),
        ],
      );

      expect(
          container.read(requiresProfileSetupProvider('/home')), true);
      expect(
          container.read(requiresProfileSetupProvider('/marketplace')),
          true);
    });

    test('returns false when authenticated with complete profile', () {
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.farmer,
        isProfileComplete: true,
      );

      container = ProviderContainer(
        overrides: [
          unifiedAuthStateProvider.overrideWith(
            (ref) => AuthState(status: AuthStatus.authenticated, user: user),
          ),
        ],
      );

      expect(
          container.read(requiresProfileSetupProvider('/home')), false);
    });

    test('returns false for non-dependent routes', () {
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.farmer,
        isProfileComplete: false,
      );

      container = ProviderContainer(
        overrides: [
          unifiedAuthStateProvider.overrideWith(
            (ref) =>
                AuthState(status: AuthStatus.profileIncomplete, user: user),
          ),
        ],
      );

      expect(
          container.read(requiresProfileSetupProvider('/welcome')), false);
      expect(
          container.read(requiresProfileSetupProvider('/profile')), false);
    });
  });
}
