import 'package:agricola/data/auth/datasources/firebase_auth_datasource.dart';
import 'package:agricola/domain/domain.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Stream<UserModel?> get authStateChanges {
    return _datasource.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getUserModelFromFirebaseUser(firebaseUser);
    });
  }

  @override
  UserModel? get currentUser {
    final firebaseUser = _datasource.currentFirebaseUser;
    if (firebaseUser == null) {
      return null;
    }

    // Note: This is sync, so we return a basic user model
    // The stream will provide the full user data asynchronously
    return UserModel.fromFirebaseUser(
      firebaseUser,
      userType: UserType.farmer, // Placeholder, will be updated by stream
      isProfileComplete: false,
    );
  }

  @override
  Future<Either<AuthFailure, void>> deleteAccount() async {
    try {
      await _datasource.deleteAccount();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<AuthFailure, UserModel>> refreshUserData() async {
    try {
      final firebaseUser = _datasource.currentFirebaseUser;
      if (firebaseUser == null) {
        return const Left(
          AuthFailure(
            message: 'No user signed in',
            type: AuthFailureType.userNotFound,
          ),
        );
      }

      // Refresh Firebase user
      await firebaseUser.reload();

      // Get updated user data
      final userModel = await _getUserModelFromFirebaseUser(firebaseUser);
      return Right(userModel);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _datasource.sendPasswordResetEmail(email);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<AuthFailure, String>> signInAnonymously() async {
    try {
      final userCredential = await _datasource.signInAnonymously();
      final userId = userCredential.user!.uid;

      return Right(userId);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<AuthFailure, UserModel>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _datasource.signInWithEmailPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;
      final userModel = await _getUserModelFromFirebaseUser(firebaseUser);

      return Right(userModel);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<AuthFailure, UserModel>> signInWithGoogle({
    required UserType userType,
    MerchantType? merchantType,
  }) async {
    try {
      final userCredential = await _datasource.signInWithGoogle();
      final firebaseUser = userCredential.user!;

      // Check if user exists in Firestore
      final userDoc = await _datasource.getUserDocument(firebaseUser.uid);

      if (userDoc.exists) {
        // Existing user - load their data
        final userData = userDoc.data() as Map<String, dynamic>;
        final userModel = UserModel.fromFirestore(userData, firebaseUser.uid);
        return Right(userModel);
      } else {
        // New user - create with provided user type
        final userModel = UserModel.fromFirebaseUser(
          firebaseUser,
          userType: userType,
          merchantType: merchantType,
          isProfileComplete: false,
        );

        await _datasource.createUserDocument(
          uid: userModel.uid,
          user: userModel,
        );

        return Right(userModel);
      }
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> signOut() async {
    try {
      await _datasource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<AuthFailure, UserModel>> signUpWithEmailPassword({
    required String email,
    required String password,
    required UserType userType,
    MerchantType? merchantType,
  }) async {
    try {
      // Create auth account
      final userCredential = await _datasource.signUpWithEmailPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;

      // Create user model
      final user = UserModel.fromFirebaseUser(
        firebaseUser,
        userType: userType,
        merchantType: merchantType,
        isProfileComplete: false,
      );

      // Save user data to Firestore
      await _datasource.createUserDocument(uid: user.uid, user: user);

      return Right(user);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> updateProfileCompletionStatus(
    bool isComplete,
  ) async {
    try {
      final firebaseUser = _datasource.currentFirebaseUser;
      if (firebaseUser == null) {
        return const Left(
          AuthFailure(
            message: 'No user signed in',
            type: AuthFailureType.userNotFound,
          ),
        );
      }

      await _datasource.updateProfileCompletionStatus(
        uid: firebaseUser.uid,
        isComplete: isComplete,
      );

      return const Right(null);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> markProfileSetupAsSkipped() async {
    try {
      final firebaseUser = _datasource.currentFirebaseUser;
      if (firebaseUser == null) {
        return const Left(
          AuthFailure(
            message: 'No user signed in',
            type: AuthFailureType.userNotFound,
          ),
        );
      }

      await _datasource.markProfileSetupAsSkipped(
        uid: firebaseUser.uid,
      );

      return const Right(null);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  /// Helper method to convert Firebase User to UserModel
  Future<UserModel> _getUserModelFromFirebaseUser(
    firebase_auth.User firebaseUser,
  ) async {
    final userDoc = await _datasource.getUserDocument(firebaseUser.uid);

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      return UserModel.fromFirestore(userData, firebaseUser.uid);
    } else {
      // Fallback for users without Firestore documents
      return UserModel.fromFirebaseUser(
        firebaseUser,
        userType: UserType.farmer,
        isProfileComplete: false,
      );
    }
  }
}
