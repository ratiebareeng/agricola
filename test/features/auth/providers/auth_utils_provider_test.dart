import 'package:agricola/domain/auth/models/user_model.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/auth/providers/auth_state_provider.dart';
import 'package:agricola/features/auth/providers/auth_utils_provider.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authRedirectRouteProvider', () {
    late ProviderContainer container;

    tearDown(() => container.dispose());

    test('returns /profile-setup?type=farmer when needsProfileSetup (farmer)',
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
          currentUserProvider.overrideWithValue(user),
        ],
      );

      expect(
        container.read(authRedirectRouteProvider),
        '/profile-setup?type=farmer',
      );
    });

    test(
        'returns /profile-setup?type=agriShop when needsProfileSetup (agriShop)',
        () {
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.merchant,
        merchantType: MerchantType.agriShop,
        isProfileComplete: false,
      );

      container = ProviderContainer(
        overrides: [
          unifiedAuthStateProvider.overrideWith(
            (ref) =>
                AuthState(status: AuthStatus.profileIncomplete, user: user),
          ),
          currentUserProvider.overrideWithValue(user),
        ],
      );

      expect(
        container.read(authRedirectRouteProvider),
        '/profile-setup?type=agriShop',
      );
    });

    test('returns /home when authenticated', () {
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
          currentUserProvider.overrideWithValue(user),
        ],
      );

      expect(container.read(authRedirectRouteProvider), '/home');
    });

    test('returns /welcome when unauthenticated', () {
      container = ProviderContainer(
        overrides: [
          unifiedAuthStateProvider.overrideWith(
            (ref) => const AuthState(status: AuthStatus.unauthenticated),
          ),
        ],
      );

      expect(container.read(authRedirectRouteProvider), '/welcome');
    });
  });

  group('userDisplayNameProvider', () {
    late ProviderContainer container;

    tearDown(() => container.dispose());

    test('returns null when no user', () {
      container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(null),
        ],
      );

      expect(container.read(userDisplayNameProvider), isNull);
    });

    test('extracts username from email', () {
      final user = UserModel(
        uid: 'uid1',
        email: 'john@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.farmer,
      );

      container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(user),
        ],
      );

      expect(container.read(userDisplayNameProvider), 'john');
    });

    test('returns User for empty email', () {
      final user = UserModel(
        uid: 'uid1',
        email: '',
        emailVerified: false,
        createdAt: DateTime(2026),
        userType: UserType.farmer,
      );

      container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(user),
        ],
      );

      expect(container.read(userDisplayNameProvider), 'User');
    });
  });

  group('userTypeDescriptionProvider', () {
    late ProviderContainer container;

    tearDown(() => container.dispose());

    test('returns Farmer for farmer user', () {
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.farmer,
      );

      container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(user)],
      );

      expect(container.read(userTypeDescriptionProvider), 'Farmer');
    });

    test('returns Agri Shop for agriShop merchant', () {
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.merchant,
        merchantType: MerchantType.agriShop,
      );

      container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(user)],
      );

      expect(container.read(userTypeDescriptionProvider), 'Agri Shop');
    });

    test('returns Supermarket Vendor for supermarketVendor merchant', () {
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.merchant,
        merchantType: MerchantType.supermarketVendor,
      );

      container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(user)],
      );

      expect(
          container.read(userTypeDescriptionProvider), 'Supermarket Vendor');
    });

    test('returns null when no user', () {
      container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(null)],
      );

      expect(container.read(userTypeDescriptionProvider), isNull);
    });
  });

  group('userTypeRouteProvider', () {
    late ProviderContainer container;

    tearDown(() => container.dispose());

    test('returns farmer for farmer user', () {
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.farmer,
      );

      container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(user)],
      );

      expect(container.read(userTypeRouteProvider), 'farmer');
    });

    test('returns agriShop for agriShop merchant', () {
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.merchant,
        merchantType: MerchantType.agriShop,
      );

      container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(user)],
      );

      expect(container.read(userTypeRouteProvider), 'agriShop');
    });

    test('returns supermarketVendor for supermarketVendor merchant', () {
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.merchant,
        merchantType: MerchantType.supermarketVendor,
      );

      container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(user)],
      );

      expect(container.read(userTypeRouteProvider), 'supermarketVendor');
    });

    test('returns null when no user', () {
      container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(null)],
      );

      expect(container.read(userTypeRouteProvider), isNull);
    });
  });

  group('canAccessFarmerFeaturesProvider', () {
    late ProviderContainer container;

    tearDown(() => container.dispose());

    test('returns true for farmer', () {
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.farmer,
      );

      container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(user)],
      );

      expect(container.read(canAccessFarmerFeaturesProvider), true);
    });

    test('returns false for merchant', () {
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.merchant,
      );

      container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(user)],
      );

      expect(container.read(canAccessFarmerFeaturesProvider), false);
    });
  });

  group('canAccessMerchantFeaturesProvider', () {
    late ProviderContainer container;

    tearDown(() => container.dispose());

    test('returns true for merchant', () {
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.merchant,
      );

      container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(user)],
      );

      expect(container.read(canAccessMerchantFeaturesProvider), true);
    });

    test('returns false for farmer', () {
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.farmer,
      );

      container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(user)],
      );

      expect(container.read(canAccessMerchantFeaturesProvider), false);
    });
  });
}
