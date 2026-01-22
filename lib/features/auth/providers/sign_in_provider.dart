import 'package:agricola/features/auth/providers/auth_controller.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final signInProvider = StateNotifierProvider<SignInNotifier, SignInState>((
  ref,
) {
  final authController = ref.watch(authControllerProvider.notifier);
  return SignInNotifier(authController, ref);
});

class SignInNotifier extends StateNotifier<SignInState> {
  final AuthController _authController;

  SignInNotifier(this._authController, Ref ref) : super(const SignInState());

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail() async {
    if (state.email.isEmpty || !state.email.contains('@')) {
      state = state.copyWith(
        errorMessage: 'Please enter a valid email address first.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authController.sendPasswordResetEmail(
        state.email.trim(),
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Password reset email sent! Check your inbox.',
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to send password reset email. Please try again.',
      );
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmailPassword(BuildContext context) async {
    if (!state.isFormValid) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authController.signInWithEmailPassword(
        email: state.email.trim(),
        password: state.password,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return false;
        },
        (user) {
          state = state.copyWith(isLoading: false);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle(BuildContext context) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authController.signInWithGoogle(
        userType: UserType.farmer,
        merchantType: null,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return false;
        },
        (user) {
          state = state.copyWith(isLoading: false);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
      return false;
    }
  }

  void updateEmail(String email) {
    state = state.copyWith(
      email: email,
      errorMessage: null,
      isFormValid: _validateForm(email, state.password),
    );
  }

  void updatePassword(String password) {
    state = state.copyWith(
      password: password,
      errorMessage: null,
      isFormValid: _validateForm(state.email, password),
    );
  }

  /// Form validation getters
  String? validateEmail() {
    if (state.email.isEmpty) return 'Email is required';
    if (!state.email.contains('@')) return 'Invalid email format';
    return null;
  }

  String? validatePassword() {
    if (state.password.isEmpty) return 'Password is required';
    return null;
  }

  bool _validateForm(String email, String password) {
    return email.isNotEmpty && email.contains('@') && password.isNotEmpty;
  }
}

class SignInState {
  final String email;
  final String password;
  final bool isLoading;
  final String? errorMessage;
  final bool isFormValid;

  const SignInState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.errorMessage,
    this.isFormValid = false,
  });

  SignInState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? errorMessage,
    bool? isFormValid,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}
