import 'package:agricola/features/auth/providers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  final authController = ref.watch(authControllerProvider.notifier);
  return ProfileNotifier(authController);
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final AuthController _authController;

  ProfileNotifier(this._authController) : super(const ProfileState());

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Delete the current user account.
  /// Navigation is handled declaratively by go_router's route guards.
  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authController.deleteAccount();

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(isLoading: false);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete account. Please try again.',
      );
      return false;
    }
  }

  /// Sign out the current user.
  /// Navigation is handled declaratively by go_router's route guards
  /// which redirect unauthenticated users to /sign-in.
  Future<bool> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authController.signOut();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to sign out. Please try again.',
      );
      return false;
    }
  }
}

class ProfileState {
  final bool isLoading;
  final String? errorMessage;

  const ProfileState({this.isLoading = false, this.errorMessage});

  ProfileState copyWith({bool? isLoading, String? errorMessage}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
