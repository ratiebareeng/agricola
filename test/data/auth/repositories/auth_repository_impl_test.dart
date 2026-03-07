import 'package:agricola/data/auth/datasources/firebase_auth_datasource.dart';
import 'package:agricola/data/auth/repositories/auth_repository_impl.dart';
import 'package:agricola/domain/auth/failures/auth_failure.dart';
import 'package:agricola/domain/auth/models/user_model.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockFirebaseAuthDatasource extends Mock
    implements FirebaseAuthDatasource {}

class MockFirebaseUser extends Mock implements firebase_auth.User {}

class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockUserMetadata extends Mock implements firebase_auth.UserMetadata {}

void main() {
  late MockFirebaseAuthDatasource mockDatasource;
  late AuthRepositoryImpl repository;
  late MockFirebaseUser mockUser;
  late MockUserCredential mockCredential;
  late MockDocumentSnapshot mockDocSnapshot;
  late MockUserMetadata mockMetadata;

  final now = DateTime(2026, 1, 15);

  setUp(() {
    mockDatasource = MockFirebaseAuthDatasource();
    repository = AuthRepositoryImpl(mockDatasource);
    mockUser = MockFirebaseUser();
    mockCredential = MockUserCredential();
    mockDocSnapshot = MockDocumentSnapshot();
    mockMetadata = MockUserMetadata();

    // Default user setup
    when(() => mockUser.uid).thenReturn('user123');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.phoneNumber).thenReturn(null);
    when(() => mockUser.emailVerified).thenReturn(true);
    when(() => mockUser.isAnonymous).thenReturn(false);
    when(() => mockUser.metadata).thenReturn(mockMetadata);
    when(() => mockMetadata.creationTime).thenReturn(now);
    when(() => mockMetadata.lastSignInTime).thenReturn(now);
    when(() => mockCredential.user).thenReturn(mockUser);
  });

  setUpAll(() {
    registerFallbackValue(UserModel(
      uid: 'fallback',
      email: 'fallback@example.com',
      emailVerified: false,
      createdAt: DateTime(2026),
      userType: UserType.farmer,
    ));
  });

  group('AuthRepositoryImpl', () {
    group('signInWithEmailPassword', () {
      test('should return UserModel on success with Firestore doc', () async {
        when(() => mockDatasource.signInWithEmailPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockCredential);

        when(() => mockDatasource.getUserDocument('user123'))
            .thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.data()).thenReturn({
          'email': 'test@example.com',
          'createdAt': Timestamp.fromDate(now),
          'userType': 'farmer',
          'isProfileComplete': true,
        });

        final result = await repository.signInWithEmailPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should be Right'),
          (user) {
            expect(user.uid, 'user123');
            expect(user.email, 'test@example.com');
            expect(user.isProfileComplete, true);
          },
        );
      });

      test('should return Left(AuthFailure) on exception', () async {
        when(() => mockDatasource.signInWithEmailPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(firebase_auth.FirebaseAuthException(
          code: 'wrong-password',
          message: 'Wrong password',
        ));

        final result = await repository.signInWithEmailPassword(
          email: 'test@example.com',
          password: 'wrong',
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.type, AuthFailureType.wrongPassword),
          (_) => fail('Should be Left'),
        );
      });
    });

    group('signUpWithEmailPassword', () {
      test('should create user doc and return UserModel on success', () async {
        when(() => mockDatasource.signUpWithEmailPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockCredential);

        when(() => mockDatasource.createUserDocument(
              uid: any(named: 'uid'),
              user: any(named: 'user'),
            )).thenAnswer((_) async {});

        final result = await repository.signUpWithEmailPassword(
          email: 'new@example.com',
          password: 'password123',
          userType: UserType.farmer,
        );

        expect(result.isRight(), true);
        verify(() => mockDatasource.createUserDocument(
              uid: 'user123',
              user: any(named: 'user'),
            )).called(1);
      });

      test('should return Left on exception', () async {
        when(() => mockDatasource.signUpWithEmailPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(firebase_auth.FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'Email in use',
        ));

        final result = await repository.signUpWithEmailPassword(
          email: 'existing@example.com',
          password: 'password123',
          userType: UserType.farmer,
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) =>
              expect(failure.type, AuthFailureType.emailAlreadyInUse),
          (_) => fail('Should be Left'),
        );
      });
    });

    group('signInWithGoogle', () {
      test('should load existing user from Firestore when doc exists',
          () async {
        when(() => mockDatasource.signInWithGoogle())
            .thenAnswer((_) async => mockCredential);
        when(() => mockDatasource.getUserDocument('user123'))
            .thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.data()).thenReturn({
          'email': 'test@gmail.com',
          'createdAt': Timestamp.fromDate(now),
          'userType': 'merchant',
          'merchantType': 'agriShop',
          'isProfileComplete': true,
        });

        final result = await repository.signInWithGoogle(
          userType: UserType.merchant,
          merchantType: MerchantType.agriShop,
        );

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should be Right'),
          (user) {
            expect(user.userType, UserType.merchant);
            expect(user.merchantType, MerchantType.agriShop);
            expect(user.isProfileComplete, true);
          },
        );
        verifyNever(() => mockDatasource.createUserDocument(
              uid: any(named: 'uid'),
              user: any(named: 'user'),
            ));
      });

      test('should create new user doc when no Firestore doc exists',
          () async {
        when(() => mockDatasource.signInWithGoogle())
            .thenAnswer((_) async => mockCredential);
        when(() => mockDatasource.getUserDocument('user123'))
            .thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(false);
        when(() => mockDatasource.createUserDocument(
              uid: any(named: 'uid'),
              user: any(named: 'user'),
            )).thenAnswer((_) async {});

        final result = await repository.signInWithGoogle(
          userType: UserType.farmer,
        );

        expect(result.isRight(), true);
        verify(() => mockDatasource.createUserDocument(
              uid: 'user123',
              user: any(named: 'user'),
            )).called(1);
      });
    });

    group('signInAnonymously', () {
      test('should return uid on success', () async {
        when(() => mockDatasource.signInAnonymously())
            .thenAnswer((_) async => mockCredential);

        final result = await repository.signInAnonymously();

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should be Right'),
          (uid) => expect(uid, 'user123'),
        );
      });

      test('should return Left on exception', () async {
        when(() => mockDatasource.signInAnonymously())
            .thenThrow(Exception('Anonymous sign-in failed'));

        final result = await repository.signInAnonymously();
        expect(result.isLeft(), true);
      });
    });

    group('signOut', () {
      test('should return Right on success', () async {
        when(() => mockDatasource.signOut()).thenAnswer((_) async {});

        final result = await repository.signOut();
        expect(result.isRight(), true);
      });

      test('should return Left on exception', () async {
        when(() => mockDatasource.signOut())
            .thenThrow(Exception('Sign out failed'));

        final result = await repository.signOut();
        expect(result.isLeft(), true);
      });
    });

    group('deleteAccount', () {
      test('should return Right on success', () async {
        when(() => mockDatasource.deleteAccount()).thenAnswer((_) async {});

        final result = await repository.deleteAccount();
        expect(result.isRight(), true);
      });

      test('should return Left on exception', () async {
        when(() => mockDatasource.deleteAccount())
            .thenThrow(Exception('Delete failed'));

        final result = await repository.deleteAccount();
        expect(result.isLeft(), true);
      });
    });

    group('sendPasswordResetEmail', () {
      test('should return Right on success', () async {
        when(() => mockDatasource.sendPasswordResetEmail(any()))
            .thenAnswer((_) async {});

        final result =
            await repository.sendPasswordResetEmail('test@example.com');
        expect(result.isRight(), true);
      });

      test('should return Left on exception', () async {
        when(() => mockDatasource.sendPasswordResetEmail(any())).thenThrow(
          firebase_auth.FirebaseAuthException(
            code: 'user-not-found',
            message: 'No user',
          ),
        );

        final result =
            await repository.sendPasswordResetEmail('missing@example.com');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.type, AuthFailureType.userNotFound),
          (_) => fail('Should be Left'),
        );
      });
    });

    group('refreshUserData', () {
      test('should return UserModel on success', () async {
        when(() => mockDatasource.currentFirebaseUser).thenReturn(mockUser);
        when(() => mockUser.reload()).thenAnswer((_) async {});
        when(() => mockDatasource.getUserDocument('user123'))
            .thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.data()).thenReturn({
          'email': 'test@example.com',
          'createdAt': Timestamp.fromDate(now),
          'userType': 'farmer',
          'isProfileComplete': true,
        });

        final result = await repository.refreshUserData();

        expect(result.isRight(), true);
      });

      test('should return userNotFound Left when no user signed in', () async {
        when(() => mockDatasource.currentFirebaseUser).thenReturn(null);

        final result = await repository.refreshUserData();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.type, AuthFailureType.userNotFound),
          (_) => fail('Should be Left'),
        );
      });
    });

    group('updateProfileCompletionStatus', () {
      test('should return Right on success', () async {
        when(() => mockDatasource.currentFirebaseUser).thenReturn(mockUser);
        when(() => mockDatasource.updateProfileCompletionStatus(
              uid: any(named: 'uid'),
              isComplete: any(named: 'isComplete'),
            )).thenAnswer((_) async {});

        final result =
            await repository.updateProfileCompletionStatus(true);
        expect(result.isRight(), true);
      });

      test('should return userNotFound when no user signed in', () async {
        when(() => mockDatasource.currentFirebaseUser).thenReturn(null);

        final result =
            await repository.updateProfileCompletionStatus(true);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.type, AuthFailureType.userNotFound),
          (_) => fail('Should be Left'),
        );
      });

      test('should return Left on exception', () async {
        when(() => mockDatasource.currentFirebaseUser).thenReturn(mockUser);
        when(() => mockDatasource.updateProfileCompletionStatus(
              uid: any(named: 'uid'),
              isComplete: any(named: 'isComplete'),
            )).thenThrow(Exception('Update failed'));

        final result =
            await repository.updateProfileCompletionStatus(true);
        expect(result.isLeft(), true);
      });
    });

    group('markProfileSetupAsSkipped', () {
      test('should return Right on success', () async {
        when(() => mockDatasource.currentFirebaseUser).thenReturn(mockUser);
        when(() => mockDatasource.markProfileSetupAsSkipped(
              uid: any(named: 'uid'),
            )).thenAnswer((_) async {});

        final result = await repository.markProfileSetupAsSkipped();
        expect(result.isRight(), true);
      });

      test('should return userNotFound when no user signed in', () async {
        when(() => mockDatasource.currentFirebaseUser).thenReturn(null);

        final result = await repository.markProfileSetupAsSkipped();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.type, AuthFailureType.userNotFound),
          (_) => fail('Should be Left'),
        );
      });

      test('should return Left on exception', () async {
        when(() => mockDatasource.currentFirebaseUser).thenReturn(mockUser);
        when(() => mockDatasource.markProfileSetupAsSkipped(
              uid: any(named: 'uid'),
            )).thenThrow(Exception('Update failed'));

        final result = await repository.markProfileSetupAsSkipped();
        expect(result.isLeft(), true);
      });
    });

    group('authStateChanges', () {
      test('should emit null for null firebase user', () async {
        when(() => mockDatasource.authStateChanges)
            .thenAnswer((_) => Stream.value(null));

        final result = await repository.authStateChanges.first;
        expect(result, isNull);
      });

      test('should emit UserModel for authenticated user', () async {
        when(() => mockDatasource.authStateChanges)
            .thenAnswer((_) => Stream.value(mockUser));
        when(() => mockDatasource.getUserDocument('user123'))
            .thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.data()).thenReturn({
          'email': 'test@example.com',
          'createdAt': Timestamp.fromDate(now),
          'userType': 'farmer',
          'isProfileComplete': true,
        });

        final result = await repository.authStateChanges.first;
        expect(result, isNotNull);
        expect(result!.uid, 'user123');
      });
    });

    group('currentUser', () {
      test('should return null when no firebase user', () {
        when(() => mockDatasource.currentFirebaseUser).thenReturn(null);
        expect(repository.currentUser, isNull);
      });

      test('should return basic UserModel when user exists', () {
        when(() => mockDatasource.currentFirebaseUser).thenReturn(mockUser);

        final user = repository.currentUser;
        expect(user, isNotNull);
        expect(user!.uid, 'user123');
        expect(user.userType, UserType.farmer); // placeholder
        expect(user.isProfileComplete, false);
      });
    });

    group('_getUserModelFromFirebaseUser', () {
      test('should load from Firestore when doc exists', () async {
        when(() => mockDatasource.signInWithEmailPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockCredential);
        when(() => mockDatasource.getUserDocument('user123'))
            .thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.data()).thenReturn({
          'email': 'test@example.com',
          'createdAt': Timestamp.fromDate(now),
          'userType': 'merchant',
          'merchantType': 'agriShop',
          'isProfileComplete': true,
        });

        final result = await repository.signInWithEmailPassword(
          email: 'test@example.com',
          password: 'pass',
        );

        result.fold(
          (_) => fail('Should be Right'),
          (user) {
            expect(user.userType, UserType.merchant);
            expect(user.merchantType, MerchantType.agriShop);
          },
        );
      });

      test('should fallback to fromFirebaseUser when no Firestore doc',
          () async {
        when(() => mockDatasource.signInWithEmailPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockCredential);
        when(() => mockDatasource.getUserDocument('user123'))
            .thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(false);

        final result = await repository.signInWithEmailPassword(
          email: 'test@example.com',
          password: 'pass',
        );

        result.fold(
          (_) => fail('Should be Right'),
          (user) {
            expect(user.uid, 'user123');
            expect(user.userType, UserType.farmer); // fallback
            expect(user.isProfileComplete, false);
          },
        );
      });
    });
  });
}
