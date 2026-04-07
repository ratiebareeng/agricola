import 'package:agricola/core/providers/analytics_provider.dart';
import 'package:agricola/core/services/analytics_service.dart';
import 'package:agricola/domain/auth/failures/auth_failure.dart';
import 'package:agricola/domain/auth/models/user_model.dart';
import 'package:agricola/features/auth/providers/auth_controller.dart';
import 'package:agricola/features/auth/providers/sign_in_provider.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthController extends Mock implements AuthController {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late MockAuthController mockAuthController;
  late SignInNotifier notifier;

  setUp(() {
    mockAuthController = MockAuthController();
    final mockAnalytics = MockAnalyticsService();
    when(() => mockAnalytics.logSigninComplete(method: any(named: 'method')))
        .thenAnswer((_) async {});
    notifier = SignInNotifier(mockAuthController, FakeRef(mockAnalytics));
  });

  group('SignInNotifier', () {
    group('updateEmail', () {
      test('should update email in state', () {
        notifier.updateEmail('test@example.com');
        expect(notifier.state.email, 'test@example.com');
      });

      test('should clear error message on update', () {
        // Set an error first
        notifier.updateEmail('bad');
        notifier.updatePassword('pass');
        // Now update email - should clear error
        notifier.updateEmail('test@example.com');
        expect(notifier.state.errorMessage, isNull);
      });

      test('should update form validity', () {
        notifier.updatePassword('password123');
        notifier.updateEmail('test@example.com');
        expect(notifier.state.isFormValid, true);
      });
    });

    group('updatePassword', () {
      test('should update password in state', () {
        notifier.updatePassword('secret123');
        expect(notifier.state.password, 'secret123');
      });

      test('should update form validity', () {
        notifier.updateEmail('test@example.com');
        notifier.updatePassword('password123');
        expect(notifier.state.isFormValid, true);
      });
    });

    group('validateEmail', () {
      test('returns error for empty email', () {
        expect(notifier.validateEmail(), 'Email is required');
      });

      test('returns error for email without @', () {
        notifier.updateEmail('invalid-email');
        expect(notifier.validateEmail(), 'Invalid email format');
      });

      test('returns null for valid email', () {
        notifier.updateEmail('test@example.com');
        expect(notifier.validateEmail(), isNull);
      });
    });

    group('validatePassword', () {
      test('returns error for empty password', () {
        expect(notifier.validatePassword(), 'Password is required');
      });

      test('returns null for non-empty password', () {
        notifier.updatePassword('password123');
        expect(notifier.validatePassword(), isNull);
      });
    });

    group('isFormValid', () {
      test('requires non-empty email with @ and non-empty password', () {
        // Initially invalid
        expect(notifier.state.isFormValid, false);

        // Email only - still invalid
        notifier.updateEmail('test@example.com');
        expect(notifier.state.isFormValid, false);

        // Both filled - valid
        notifier.updatePassword('password123');
        expect(notifier.state.isFormValid, true);
      });

      test('is false when email has no @', () {
        notifier.updateEmail('invalid');
        notifier.updatePassword('password123');
        expect(notifier.state.isFormValid, false);
      });
    });

    group('signInWithEmailPassword', () {
      final testUser = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.farmer,
      );

      test('returns false immediately when form is invalid', () async {
        // Form is empty, so invalid
        final result =
            await notifier.signInWithEmailPassword(_FakeBuildContext());
        expect(result, false);
      });

      test('returns true and clears loading on success', () async {
        notifier.updateEmail('test@example.com');
        notifier.updatePassword('password123');

        when(() => mockAuthController.signInWithEmailPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => Right(testUser));

        final result =
            await notifier.signInWithEmailPassword(_FakeBuildContext());

        expect(result, true);
        expect(notifier.state.isLoading, false);
      });

      test('returns false and sets errorMessage on failure', () async {
        notifier.updateEmail('test@example.com');
        notifier.updatePassword('wrong');

        when(() => mockAuthController.signInWithEmailPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => const Left(AuthFailure(
              message: 'Incorrect password',
              type: AuthFailureType.wrongPassword,
            )));

        final result =
            await notifier.signInWithEmailPassword(_FakeBuildContext());

        expect(result, false);
        expect(notifier.state.isLoading, false);
        expect(notifier.state.errorMessage, 'Incorrect password');
      });
    });

    group('signInWithGoogle', () {
      final testUser = UserModel(
        uid: 'uid1',
        email: 'test@gmail.com',
        emailVerified: true,
        createdAt: DateTime(2026),
        userType: UserType.farmer,
      );

      setUp(() {
        registerFallbackValue(UserType.farmer);
      });

      test('returns true on success', () async {
        when(() => mockAuthController.signInWithGoogle(
              userType: any(named: 'userType'),
              merchantType: any(named: 'merchantType'),
            )).thenAnswer((_) async => Right(testUser));

        final result =
            await notifier.signInWithGoogle(_FakeBuildContext());

        expect(result, true);
        expect(notifier.state.isLoading, false);
      });

      test('returns false and sets error on failure', () async {
        when(() => mockAuthController.signInWithGoogle(
              userType: any(named: 'userType'),
              merchantType: any(named: 'merchantType'),
            )).thenAnswer((_) async => const Left(AuthFailure(
              message: 'Google sign-in failed',
              type: AuthFailureType.unknown,
            )));

        final result =
            await notifier.signInWithGoogle(_FakeBuildContext());

        expect(result, false);
        expect(notifier.state.errorMessage, 'Google sign-in failed');
      });

      test('handles unexpected exception', () async {
        when(() => mockAuthController.signInWithGoogle(
              userType: any(named: 'userType'),
              merchantType: any(named: 'merchantType'),
            )).thenThrow(Exception('Unexpected'));

        final result =
            await notifier.signInWithGoogle(_FakeBuildContext());

        expect(result, false);
        expect(notifier.state.errorMessage,
            'An unexpected error occurred. Please try again.');
      });
    });

    group('sendPasswordResetEmail', () {
      test('returns true on success', () async {
        notifier.updateEmail('test@example.com');

        when(() => mockAuthController.sendPasswordResetEmail(any()))
            .thenAnswer((_) async => const Right(null));

        final result = await notifier.sendPasswordResetEmail();

        expect(result, true);
        expect(notifier.state.isLoading, false);
        expect(notifier.state.errorMessage,
            'Password reset email sent! Check your inbox.');
      });

      test('returns false on failure', () async {
        notifier.updateEmail('test@example.com');

        when(() => mockAuthController.sendPasswordResetEmail(any()))
            .thenAnswer((_) async => const Left(AuthFailure(
                  message: 'No user found',
                  type: AuthFailureType.userNotFound,
                )));

        final result = await notifier.sendPasswordResetEmail();

        expect(result, false);
        expect(notifier.state.errorMessage, 'No user found');
      });

      test('returns false for empty email', () async {
        final result = await notifier.sendPasswordResetEmail();

        expect(result, false);
        expect(notifier.state.errorMessage,
            'Please enter a valid email address first.');
      });

      test('returns false for invalid email (no @)', () async {
        notifier.updateEmail('invalid-email');

        final result = await notifier.sendPasswordResetEmail();

        expect(result, false);
        expect(notifier.state.errorMessage,
            'Please enter a valid email address first.');
      });
    });

    group('clearError', () {
      test('resets errorMessage to null', () {
        notifier.updateEmail('test@example.com');
        // Force an error state
        notifier.clearError();
        expect(notifier.state.errorMessage, isNull);
      });
    });
  });
}

// Fakes for test-only use
class _FakeBuildContext extends Fake implements BuildContext {}

class FakeRef extends Fake implements Ref<Object?> {
  FakeRef(this.analytics);
  final MockAnalyticsService analytics;

  @override
  T read<T>(ProviderListenable<T> provider) {
    if (identical(provider, analyticsServiceProvider)) {
      return analytics as T;
    }
    throw UnimplementedError('FakeRef.read not implemented for $provider');
  }
}
