import 'package:agricola/domain/domain.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/profile/domain/models/profile_response.dart';
import 'package:agricola/features/profile/providers/profile_controller_provider.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return AuthController(repository, ref);
    });

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthController(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<Either<AuthFailure, void>> deleteAccount() async {
    state = const AsyncValue.loading();

    // Delete profile from backend before deleting account
    final user = _ref.read(currentUserProvider);
    if (user != null) {
      // Get current profile to get the profileId
      final profile = _ref.read(currentProfileProvider);
      if (profile != null) {
        final profileId = profile.id;
        await _ref
            .read(profileControllerProvider.notifier)
            .deleteProfile(profileId: profileId);
      }
    }

    final result = await _repository.deleteAccount();

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );

    return result;
  }

  Future<void> markProfileAsComplete() async {
    await _repository.updateProfileCompletionStatus(true);
  }

  Future<Either<AuthFailure, UserModel>> refreshUserData() async {
    return await _repository.refreshUserData();
  }

  Future<Either<AuthFailure, void>> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();

    final result = await _repository.sendPasswordResetEmail(email);

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );

    return result;
  }

  Future<Either<AuthFailure, String>> signInAnonymously() async {
    state = const AsyncValue.loading();

    final result = await _repository.signInAnonymously();

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );

    return result;
  }

  Future<Either<AuthFailure, UserModel>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.signInWithEmailPassword(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) {
        state = const AsyncValue.data(null);
        // Load profile if profile is complete
        if (user.isProfileComplete) {
          _ref
              .read(profileControllerProvider.notifier)
              .loadProfile(userId: user.uid);
        }
      },
    );

    return result;
  }

  Future<Either<AuthFailure, UserModel>> signInWithGoogle({
    required UserType userType,
    MerchantType? merchantType,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.signInWithGoogle(
      userType: userType,
      merchantType: merchantType,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) {
        state = const AsyncValue.data(null);
        if (user.isProfileComplete) {
          _ref
              .read(profileControllerProvider.notifier)
              .loadProfile(userId: user.uid);
        }
      },
    );

    return result;
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();

    // Clear profile before signing out
    await _ref.read(profileControllerProvider.notifier).clearProfile();

    // Clear user-specific cached data from SharedPreferences
    // This prevents the next user from seeing the wrong dashboard
    // NOTE: We preserve app-wide flags (has_seen_welcome, has_seen_onboarding)
    // so returning users don't have to go through onboarding again
    final prefs = await SharedPreferences.getInstance();

    // Keys to preserve (app-wide, not user-specific)
    const keysToPreserve = [
      'has_seen_welcome',
      'has_seen_onboarding',
      'language_code',
    ];

    // Get all keys and remove only user-specific ones
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (!keysToPreserve.contains(key)) {
        await prefs.remove(key);
      }
    }

    final result = await _repository.signOut();

    result.fold((failure) {
      state = AsyncValue.error(failure, StackTrace.current);
      if (kDebugMode) {
        print('Sign out error: ${failure.message}');
      }
    }, (_) => state = const AsyncValue.data(null));
  }

  Future<Either<AuthFailure, UserModel>> signUpWithEmailPassword({
    required String email,
    required String password,
    required UserType userType,
    MerchantType? merchantType,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.signUpWithEmailPassword(
      email: email,
      password: password,
      userType: userType,
      merchantType: merchantType,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );

    return result;
  }
}
