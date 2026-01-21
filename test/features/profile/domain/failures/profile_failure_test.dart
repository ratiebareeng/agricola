import 'package:agricola/features/profile/domain/failures/profile_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileFailure', () {
    group('constructor', () {
      test('should create instance with required parameters', () {
        final failure = ProfileFailure(
          message: 'Profile not found',
          type: ProfileFailureType.notFound,
        );

        expect(failure.message, 'Profile not found');
        expect(failure.type, ProfileFailureType.notFound);
        expect(failure.originalError, isNull);
      });

      test('should create instance with original error', () {
        final originalError = Exception('Original error');
        final failure = ProfileFailure(
          message: 'An error occurred',
          type: ProfileFailureType.unknown,
          originalError: originalError,
        );

        expect(failure.originalError, originalError);
      });
    });

    group('fromException', () {
      test('should return same ProfileFailure if already ProfileFailure', () {
        final originalFailure = ProfileFailure(
          message: 'Test failure',
          type: ProfileFailureType.networkError,
        );

        final result = ProfileFailure.fromException(originalFailure);

        expect(result, originalFailure);
      });

      test('should create unknown failure for generic exception', () {
        final exception = Exception('Generic error');
        final failure = ProfileFailure.fromException(exception);

        expect(failure.type, ProfileFailureType.unknown);
        expect(failure.message, contains('Exception: Generic error'));
        expect(failure.originalError, exception);
      });

      test('should create unknown failure for any object', () {
        const error = 'String error';
        final failure = ProfileFailure.fromException(error);

        expect(failure.type, ProfileFailureType.unknown);
        expect(failure.message, 'String error');
        expect(failure.originalError, error);
      });
    });

    group('factory constructors', () {
      test('notFound should create not found failure', () {
        final failure = ProfileFailure.notFound('Profile not found');

        expect(failure.type, ProfileFailureType.notFound);
        expect(failure.message, 'Profile not found');
        expect(failure.originalError, isNull);
      });

      test('alreadyExists should create already exists failure', () {
        final failure = ProfileFailure.alreadyExists('Profile already exists');

        expect(failure.type, ProfileFailureType.alreadyExists);
        expect(failure.message, 'Profile already exists');
        expect(failure.originalError, isNull);
      });

      test('invalidData should create invalid data failure', () {
        final failure = ProfileFailure.invalidData('Invalid profile data');

        expect(failure.type, ProfileFailureType.invalidData);
        expect(failure.message, 'Invalid profile data');
        expect(failure.originalError, isNull);
      });

      test('networkError should create network error failure', () {
        final failure = ProfileFailure.networkError(
          'Network connection failed',
        );

        expect(failure.type, ProfileFailureType.networkError);
        expect(failure.message, 'Network connection failed');
        expect(failure.originalError, isNull);
      });

      test('serverError should create server error failure', () {
        final failure = ProfileFailure.serverError('Internal server error');

        expect(failure.type, ProfileFailureType.serverError);
        expect(failure.message, 'Internal server error');
        expect(failure.originalError, isNull);
      });

      test('unauthorized should create unauthorized failure', () {
        final failure = ProfileFailure.unauthorized('Unauthorized access');

        expect(failure.type, ProfileFailureType.unauthorized);
        expect(failure.message, 'Unauthorized access');
        expect(failure.originalError, isNull);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties are equal', () {
        final failure1 = ProfileFailure(
          message: 'Test error',
          type: ProfileFailureType.networkError,
        );

        final failure2 = ProfileFailure(
          message: 'Test error',
          type: ProfileFailureType.networkError,
        );

        expect(failure1, failure2);
        expect(failure1.hashCode, failure2.hashCode);
      });

      test('should not be equal when messages differ', () {
        final failure1 = ProfileFailure(
          message: 'Error 1',
          type: ProfileFailureType.networkError,
        );

        final failure2 = ProfileFailure(
          message: 'Error 2',
          type: ProfileFailureType.networkError,
        );

        expect(failure1, isNot(failure2));
      });

      test('should not be equal when types differ', () {
        final failure1 = ProfileFailure(
          message: 'Test error',
          type: ProfileFailureType.networkError,
        );

        final failure2 = ProfileFailure(
          message: 'Test error',
          type: ProfileFailureType.serverError,
        );

        expect(failure1, isNot(failure2));
      });

      test('should consider originalError in equality', () {
        final error = Exception('Original');

        final failure1 = ProfileFailure(
          message: 'Test error',
          type: ProfileFailureType.unknown,
          originalError: error,
        );

        final failure2 = ProfileFailure(
          message: 'Test error',
          type: ProfileFailureType.unknown,
          originalError: error,
        );

        expect(failure1, failure2);
      });
    });

    group('toString', () {
      test('should return formatted string with type and message', () {
        final failure = ProfileFailure(
          message: 'Profile not found',
          type: ProfileFailureType.notFound,
        );

        expect(
          failure.toString(),
          'ProfileFailure(ProfileFailureType.notFound): Profile not found',
        );
      });

      test('should return formatted string for all failure types', () {
        final types = [
          ProfileFailureType.notFound,
          ProfileFailureType.alreadyExists,
          ProfileFailureType.invalidData,
          ProfileFailureType.networkError,
          ProfileFailureType.serverError,
          ProfileFailureType.unauthorized,
          ProfileFailureType.unknown,
        ];

        for (final type in types) {
          final failure = ProfileFailure(message: 'Test message', type: type);

          expect(
            failure.toString(),
            'ProfileFailure(ProfileFailureType.${type.name}): Test message',
          );
        }
      });
    });

    group('ProfileFailureType', () {
      test('should have all expected enum values', () {
        expect(ProfileFailureType.values.length, 7);
        expect(
          ProfileFailureType.values,
          contains(ProfileFailureType.notFound),
        );
        expect(
          ProfileFailureType.values,
          contains(ProfileFailureType.alreadyExists),
        );
        expect(
          ProfileFailureType.values,
          contains(ProfileFailureType.invalidData),
        );
        expect(
          ProfileFailureType.values,
          contains(ProfileFailureType.networkError),
        );
        expect(
          ProfileFailureType.values,
          contains(ProfileFailureType.serverError),
        );
        expect(
          ProfileFailureType.values,
          contains(ProfileFailureType.unauthorized),
        );
        expect(ProfileFailureType.values, contains(ProfileFailureType.unknown));
      });
    });
  });
}
