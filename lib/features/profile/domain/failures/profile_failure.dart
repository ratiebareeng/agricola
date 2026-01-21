import 'package:equatable/equatable.dart';

enum ProfileFailureType {
  notFound,
  alreadyExists,
  invalidData,
  networkError,
  serverError,
  unauthorized,
  unknown,
}

class ProfileFailure extends Equatable {
  final String message;
  final ProfileFailureType type;
  final dynamic originalError;

  const ProfileFailure({
    required this.message,
    required this.type,
    this.originalError,
  });

  factory ProfileFailure.fromException(Object e) {
    if (e is ProfileFailure) {
      return e;
    }
    return ProfileFailure(
      message: e.toString(),
      type: ProfileFailureType.unknown,
      originalError: e,
    );
  }

  factory ProfileFailure.notFound(String message) {
    return ProfileFailure(
      message: message,
      type: ProfileFailureType.notFound,
    );
  }

  factory ProfileFailure.alreadyExists(String message) {
    return ProfileFailure(
      message: message,
      type: ProfileFailureType.alreadyExists,
    );
  }

  factory ProfileFailure.invalidData(String message) {
    return ProfileFailure(
      message: message,
      type: ProfileFailureType.invalidData,
    );
  }

  factory ProfileFailure.networkError(String message) {
    return ProfileFailure(
      message: message,
      type: ProfileFailureType.networkError,
    );
  }

  factory ProfileFailure.serverError(String message) {
    return ProfileFailure(
      message: message,
      type: ProfileFailureType.serverError,
    );
  }

  factory ProfileFailure.unauthorized(String message) {
    return ProfileFailure(
      message: message,
      type: ProfileFailureType.unauthorized,
    );
  }

  @override
  List<Object?> get props => [message, type, originalError];

  @override
  String toString() => 'ProfileFailure($type): $message';
}
