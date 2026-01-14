import 'package:agricola/features/auth/providers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return ProfileNotifier(authController);
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final AuthController _authController;

  ProfileNotifier(this._authController) : super(const ProfileState());

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Sign out the current user
  Future<bool> signOut(BuildContext context) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authController.signOut();
      state = state.copyWith(isLoading: false);
      
      // Navigate to welcome screen after successful sign out
      if (context.mounted) {
        context.go('/welcome');
      }
      
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

  const ProfileState({
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
