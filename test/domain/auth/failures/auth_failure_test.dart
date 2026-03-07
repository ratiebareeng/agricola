import 'package:agricola/domain/auth/failures/auth_failure.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthFailure', () {
    group('fromFirebaseException', () {
      final errorCases = <String, (AuthFailureType, String)>{
        'user-not-found': (
          AuthFailureType.userNotFound,
          'No user found with this email',
        ),
        'wrong-password': (
          AuthFailureType.wrongPassword,
          'Incorrect password',
        ),
        'email-already-in-use': (
          AuthFailureType.emailAlreadyInUse,
          'An account with this email already exists',
        ),
        'invalid-email': (
          AuthFailureType.invalidEmail,
          'Invalid email address',
        ),
        'weak-password': (
          AuthFailureType.weakPassword,
          'Password should be at least 6 characters',
        ),
        'operation-not-allowed': (
          AuthFailureType.operationNotAllowed,
          'This sign-in method is not enabled',
        ),
        'user-disabled': (
          AuthFailureType.userDisabled,
          'This account has been disabled',
        ),
        'too-many-requests': (
          AuthFailureType.tooManyRequests,
          'Too many attempts. Please try again later',
        ),
        'network-request-failed': (
          AuthFailureType.networkError,
          'Network error. Check your connection',
        ),
        'account-exists-with-different-credential': (
          AuthFailureType.accountExistsWithDifferentCredential,
          'Account exists with different sign-in method',
        ),
        'invalid-credential': (
          AuthFailureType.invalidCredential,
          'Invalid credentials provided',
        ),
      };

      for (final entry in errorCases.entries) {
        test('should map "${entry.key}" to ${entry.value.$1}', () {
          final exception = FirebaseAuthException(
            code: entry.key,
            message: 'Firebase error',
          );

          final failure = AuthFailure.fromFirebaseException(exception);

          expect(failure.type, entry.value.$1);
          expect(failure.message, entry.value.$2);
        });
      }

      test('should map unknown code to AuthFailureType.unknown', () {
        final exception = FirebaseAuthException(
          code: 'some-unknown-code',
          message: 'Something went wrong',
        );

        final failure = AuthFailure.fromFirebaseException(exception);

        expect(failure.type, AuthFailureType.unknown);
        expect(failure.message, 'Something went wrong');
      });

      test('should use default message when Firebase message is null', () {
        final exception = FirebaseAuthException(
          code: 'some-unknown-code',
          message: null,
        );

        final failure = AuthFailure.fromFirebaseException(exception);

        expect(failure.type, AuthFailureType.unknown);
        expect(failure.message, 'An unexpected error occurred');
      });
    });

    group('fromException', () {
      test('should delegate FirebaseAuthException to fromFirebaseException', () {
        final exception = FirebaseAuthException(
          code: 'user-not-found',
          message: 'Not found',
        );

        final failure = AuthFailure.fromException(exception);

        expect(failure.type, AuthFailureType.userNotFound);
        expect(failure.message, 'No user found with this email');
      });

      test('should map non-Firebase exception to unknown', () {
        final exception = Exception('Generic error');

        final failure = AuthFailure.fromException(exception);

        expect(failure.type, AuthFailureType.unknown);
        expect(failure.message, contains('Generic error'));
      });
    });

    group('AuthFailureType enum', () {
      test('should have all 12 values', () {
        expect(AuthFailureType.values.length, 12);
        expect(AuthFailureType.values, contains(AuthFailureType.userNotFound));
        expect(AuthFailureType.values, contains(AuthFailureType.wrongPassword));
        expect(
          AuthFailureType.values,
          contains(AuthFailureType.emailAlreadyInUse),
        );
        expect(AuthFailureType.values, contains(AuthFailureType.invalidEmail));
        expect(AuthFailureType.values, contains(AuthFailureType.weakPassword));
        expect(
          AuthFailureType.values,
          contains(AuthFailureType.operationNotAllowed),
        );
        expect(AuthFailureType.values, contains(AuthFailureType.userDisabled));
        expect(
          AuthFailureType.values,
          contains(AuthFailureType.tooManyRequests),
        );
        expect(AuthFailureType.values, contains(AuthFailureType.networkError));
        expect(
          AuthFailureType.values,
          contains(AuthFailureType.accountExistsWithDifferentCredential),
        );
        expect(
          AuthFailureType.values,
          contains(AuthFailureType.invalidCredential),
        );
        expect(AuthFailureType.values, contains(AuthFailureType.unknown));
      });
    });
  });
}
