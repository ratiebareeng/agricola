import 'package:agricola/domain/domain.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/auth/providers/auth_controller.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/profile/domain/models/profile_response.dart';
import 'package:agricola/features/profile/providers/profile_controller_provider.dart';
import 'package:agricola/features/profile/providers/profile_state_notifier.dart';
import 'package:agricola/features/profile_setup/models/farmer_profile_model.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late MockProfileStateNotifier mockProfileNotifier;
  late ProviderContainer container;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(UserType.farmer);
    registerFallbackValue(MerchantType.agriShop);
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockProfileNotifier = MockProfileStateNotifier();

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        profileControllerProvider.overrideWith((ref) => mockProfileNotifier),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthController - Profile Integration Tests', () {
    group('signInWithEmailPassword', () {
      test('should load profile when user has completed profile', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final user = UserModel(
          uid: 'user123',
          email: email,
          emailVerified: true,
          userType: UserType.farmer,
          isProfileComplete: true,
          createdAt: DateTime.now(),
        );

        when(
          () => mockAuthRepository.signInWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => Right(user));

        when(
          () => mockProfileNotifier.loadProfile(
            userId: any(named: 'userId'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => true);

        final controller = container.read(authControllerProvider.notifier);

        // Act
        final result = await controller.signInWithEmailPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isRight(), true);
        verify(
          () => mockAuthRepository.signInWithEmailPassword(
            email: email,
            password: password,
          ),
        ).called(1);
        verify(
          () => mockProfileNotifier.loadProfile(userId: user.uid),
        ).called(1);
      });

      test(
        'should NOT load profile when user has incomplete profile',
        () async {
          // Arrange
          const email = 'test@example.com';
          const password = 'password123';
          final user = UserModel(
            uid: 'user123',
            email: email,
            emailVerified: true,
            userType: UserType.farmer,
            isProfileComplete: false,
            createdAt: DateTime.now(),
          );

          when(
            () => mockAuthRepository.signInWithEmailPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => Right(user));

          final controller = container.read(authControllerProvider.notifier);

          // Act
          final result = await controller.signInWithEmailPassword(
            email: email,
            password: password,
          );

          // Assert
          expect(result.isRight(), true);
          verify(
            () => mockAuthRepository.signInWithEmailPassword(
              email: email,
              password: password,
            ),
          ).called(1);
          verifyNever(
            () => mockProfileNotifier.loadProfile(userId: any(named: 'userId')),
          );
        },
      );

      test('should handle auth failure without loading profile', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';
        const failure = AuthFailure(
          message: 'Invalid credentials',
          type: AuthFailureType.invalidCredential,
        );

        when(
          () => mockAuthRepository.signInWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => const Left(failure));

        final controller = container.read(authControllerProvider.notifier);

        // Act
        final result = await controller.signInWithEmailPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isLeft(), true);
        verifyNever(
          () => mockProfileNotifier.loadProfile(userId: any(named: 'userId')),
        );
      });
    });

    group('signInWithGoogle', () {
      test('should load profile when user has completed profile', () async {
        // Arrange
        final user = UserModel(
          uid: 'user123',
          email: 'test@gmail.com',
          emailVerified: true,
          userType: UserType.merchant,
          merchantType: MerchantType.agriShop,
          isProfileComplete: true,
          createdAt: DateTime.now(),
        );

        when(
          () => mockAuthRepository.signInWithGoogle(
            userType: any(named: 'userType'),
            merchantType: any(named: 'merchantType'),
          ),
        ).thenAnswer((_) async => Right(user));

        when(
          () => mockProfileNotifier.loadProfile(
            userId: any(named: 'userId'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => true);

        final controller = container.read(authControllerProvider.notifier);

        // Act
        final result = await controller.signInWithGoogle(
          userType: UserType.merchant,
          merchantType: MerchantType.agriShop,
        );

        // Assert
        expect(result.isRight(), true);
        verify(
          () => mockProfileNotifier.loadProfile(userId: user.uid),
        ).called(1);
      });

      test(
        'should NOT load profile when user has incomplete profile',
        () async {
          // Arrange
          final user = UserModel(
            uid: 'user123',
            email: 'test@gmail.com',
            emailVerified: true,
            userType: UserType.farmer,
            isProfileComplete: false,
            createdAt: DateTime.now(),
          );

          when(
            () => mockAuthRepository.signInWithGoogle(
              userType: any(named: 'userType'),
              merchantType: any(named: 'merchantType'),
            ),
          ).thenAnswer((_) async => Right(user));

          final controller = container.read(authControllerProvider.notifier);

          // Act
          final result = await controller.signInWithGoogle(
            userType: UserType.farmer,
          );

          // Assert
          expect(result.isRight(), true);
          verifyNever(
            () => mockProfileNotifier.loadProfile(userId: any(named: 'userId')),
          );
        },
      );
    });

    group('signOut', () {
      test('should clear profile before signing out', () async {
        // Arrange
        when(
          () => mockProfileNotifier.clearProfile(),
        ).thenAnswer((_) async => {});
        when(
          () => mockAuthRepository.signOut(),
        ).thenAnswer((_) async => const Right(null));

        final controller = container.read(authControllerProvider.notifier);

        // Act
        await controller.signOut();

        // Assert
        verify(() => mockProfileNotifier.clearProfile()).called(1);
        verify(() => mockAuthRepository.signOut()).called(1);
      });

      test('should clear profile even if sign out fails', () async {
        // Arrange
        when(
          () => mockProfileNotifier.clearProfile(),
        ).thenAnswer((_) async => {});
        when(() => mockAuthRepository.signOut()).thenAnswer(
          (_) async => const Left(
            AuthFailure(message: 'Server error', type: AuthFailureType.unknown),
          ),
        );

        final controller = container.read(authControllerProvider.notifier);

        // Act
        await controller.signOut();

        // Assert - Profile should be cleared even on failure
        verify(() => mockProfileNotifier.clearProfile()).called(1);
        verify(() => mockAuthRepository.signOut()).called(1);
      });
    });

    group('deleteAccount', () {
      test(
        'should delete profile before deleting account when profile exists',
        () async {
          // Arrange
          final user = UserModel(
            uid: 'user123',
            email: 'test@example.com',
            emailVerified: true,
            userType: UserType.farmer,
            isProfileComplete: true,
            createdAt: DateTime.now(),
          );

          final profile = FarmerProfileResponse(
            FarmerProfileModel(
              id: 'profile123',
              userId: user.uid,
              village: 'Test Village',
              primaryCrops: ['Maize'],
              farmSize: 'Small',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

          // Setup container with user and profile
          final testContainer = ProviderContainer(
            overrides: [
              authRepositoryProvider.overrideWithValue(mockAuthRepository),
              profileControllerProvider.overrideWith(
                (ref) => mockProfileNotifier,
              ),
              currentUserProvider.overrideWithValue(user),
              currentProfileProvider.overrideWithValue(profile),
            ],
          );

          when(
            () => mockProfileNotifier.deleteProfile(
              profileId: any(named: 'profileId'),
            ),
          ).thenAnswer((_) async => true);

          when(
            () => mockAuthRepository.deleteAccount(),
          ).thenAnswer((_) async => const Right(null));

          final controller = testContainer.read(
            authControllerProvider.notifier,
          );

          // Act
          final result = await controller.deleteAccount();

          // Assert
          expect(result.isRight(), true);
          verify(
            () => mockProfileNotifier.deleteProfile(profileId: 'profile123'),
          ).called(1);
          verify(() => mockAuthRepository.deleteAccount()).called(1);

          testContainer.dispose();
        },
      );

      test('should delete account even if profile deletion fails', () async {
        // Arrange
        final user = UserModel(
          uid: 'user123',
          email: 'test@example.com',
          emailVerified: true,
          userType: UserType.farmer,
          isProfileComplete: true,
          createdAt: DateTime.now(),
        );

        final profile = FarmerProfileResponse(
          FarmerProfileModel(
            id: 'profile123',
            userId: user.uid,
            village: 'Test Village',
            primaryCrops: ['Maize'],
            farmSize: 'Small',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        final testContainer = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            profileControllerProvider.overrideWith(
              (ref) => mockProfileNotifier,
            ),
            currentUserProvider.overrideWithValue(user),
            currentProfileProvider.overrideWithValue(profile),
          ],
        );

        when(
          () => mockProfileNotifier.deleteProfile(
            profileId: any(named: 'profileId'),
          ),
        ).thenAnswer((_) async => false); // Profile deletion fails

        when(
          () => mockAuthRepository.deleteAccount(),
        ).thenAnswer((_) async => const Right(null));

        final controller = testContainer.read(authControllerProvider.notifier);

        // Act
        final result = await controller.deleteAccount();

        // Assert - Should still attempt account deletion
        expect(result.isRight(), true);
        verify(() => mockAuthRepository.deleteAccount()).called(1);

        testContainer.dispose();
      });

      test('should skip profile deletion when no profile exists', () async {
        // Arrange
        final user = UserModel(
          uid: 'user123',
          email: 'test@example.com',
          emailVerified: true,
          userType: UserType.farmer,
          isProfileComplete: false, // No profile
          createdAt: DateTime.now(),
        );

        final testContainer = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            profileControllerProvider.overrideWith(
              (ref) => mockProfileNotifier,
            ),
            currentUserProvider.overrideWithValue(user),
            currentProfileProvider.overrideWithValue(null), // No profile
          ],
        );

        when(
          () => mockAuthRepository.deleteAccount(),
        ).thenAnswer((_) async => const Right(null));

        final controller = testContainer.read(authControllerProvider.notifier);

        // Act
        final result = await controller.deleteAccount();

        // Assert
        expect(result.isRight(), true);
        verifyNever(
          () => mockProfileNotifier.deleteProfile(
            profileId: any(named: 'profileId'),
          ),
        );
        verify(() => mockAuthRepository.deleteAccount()).called(1);

        testContainer.dispose();
      });

      test('should skip profile deletion when no user is signed in', () async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            profileControllerProvider.overrideWith(
              (ref) => mockProfileNotifier,
            ),
            currentUserProvider.overrideWithValue(null), // No user
          ],
        );

        when(
          () => mockAuthRepository.deleteAccount(),
        ).thenAnswer((_) async => const Right(null));

        final controller = testContainer.read(authControllerProvider.notifier);

        // Act
        final result = await controller.deleteAccount();

        // Assert
        expect(result.isRight(), true);
        verifyNever(
          () => mockProfileNotifier.deleteProfile(
            profileId: any(named: 'profileId'),
          ),
        );
        verify(() => mockAuthRepository.deleteAccount()).called(1);

        testContainer.dispose();
      });
    });

    group('markProfileAsComplete', () {
      test('should update profile completion status', () async {
        // Arrange
        when(
          () => mockAuthRepository.updateProfileCompletionStatus(true),
        ).thenAnswer((_) async => const Right(null));

        final controller = container.read(authControllerProvider.notifier);

        // Act
        await controller.markProfileAsComplete();

        // Assert
        verify(
          () => mockAuthRepository.updateProfileCompletionStatus(true),
        ).called(1);
      });
    });
  });
}

// Mocks
class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileStateNotifier extends Mock implements ProfileStateNotifier {}
