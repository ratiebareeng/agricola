import 'package:agricola/domain/auth/failures/auth_failure.dart';
import 'package:agricola/domain/auth/models/user_model.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:fpdart/fpdart.dart';

abstract class AuthRepository {
  Stream<UserModel?> get authStateChanges;

  UserModel? get currentUser;

  Future<Either<AuthFailure, void>> deleteAccount();

  Future<Either<AuthFailure, UserModel>> refreshUserData();

  Future<Either<AuthFailure, void>> sendPasswordResetEmail(String email);

  Future<Either<AuthFailure, UserModel>> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Either<AuthFailure, UserModel>> signInWithGoogle({
    required UserType userType,
    MerchantType? merchantType,
  });

  Future<Either<AuthFailure, void>> signOut();

  Future<Either<AuthFailure, UserModel>> signUpWithEmailPassword({
    required String email,
    required String password,
    required UserType userType,
    MerchantType? merchantType,
  });

  Future<Either<AuthFailure, void>> updateProfileCompletionStatus(
    bool isComplete,
  );
}
