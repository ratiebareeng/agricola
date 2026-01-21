import 'package:firebase_auth/firebase_auth.dart';

class AuthFailure {
  final String message;
  final AuthFailureType type;

  const AuthFailure({
    required this.message,
    required this.type,
  });

  factory AuthFailure.fromException(Object e) {
    if (e is FirebaseAuthException) {
      return AuthFailure.fromFirebaseException(e);
    }
    return AuthFailure(
      message: e.toString(),
      type: AuthFailureType.unknown,
    );
  }

  factory AuthFailure.fromFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthFailure(
          message: 'No user found with this email',
          type: AuthFailureType.userNotFound,
        );
      case 'wrong-password':
        return const AuthFailure(
          message: 'Incorrect password',
          type: AuthFailureType.wrongPassword,
        );
      case 'email-already-in-use':
        return const AuthFailure(
          message: 'An account with this email already exists',
          type: AuthFailureType.emailAlreadyInUse,
        );
      case 'invalid-email':
        return const AuthFailure(
          message: 'Invalid email address',
          type: AuthFailureType.invalidEmail,
        );
      case 'weak-password':
        return const AuthFailure(
          message: 'Password should be at least 6 characters',
          type: AuthFailureType.weakPassword,
        );
      case 'operation-not-allowed':
        return const AuthFailure(
          message: 'This sign-in method is not enabled',
          type: AuthFailureType.operationNotAllowed,
        );
      case 'user-disabled':
        return const AuthFailure(
          message: 'This account has been disabled',
          type: AuthFailureType.userDisabled,
        );
      case 'too-many-requests':
        return const AuthFailure(
          message: 'Too many attempts. Please try again later',
          type: AuthFailureType.tooManyRequests,
        );
      case 'network-request-failed':
        return const AuthFailure(
          message: 'Network error. Check your connection',
          type: AuthFailureType.networkError,
        );
      case 'account-exists-with-different-credential':
        return const AuthFailure(
          message: 'Account exists with different sign-in method',
          type: AuthFailureType.accountExistsWithDifferentCredential,
        );
      case 'invalid-credential':
        return const AuthFailure(
          message: 'Invalid credentials provided',
          type: AuthFailureType.invalidCredential,
        );
      default:
        return AuthFailure(
          message: e.message ?? 'An unexpected error occurred',
          type: AuthFailureType.unknown,
        );
    }
  }
}

enum AuthFailureType {
  userNotFound,
  wrongPassword,
  emailAlreadyInUse,
  invalidEmail,
  weakPassword,
  operationNotAllowed,
  userDisabled,
  tooManyRequests,
  networkError,
  accountExistsWithDifferentCredential,
  invalidCredential,
  unknown,
}
