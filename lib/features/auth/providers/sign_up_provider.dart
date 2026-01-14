import 'package:agricola/features/auth/providers/auth_controller.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final signUpProvider = StateNotifierProvider<SignUpNotifier, SignUpState>((
  ref,
) {
  final authController = ref.watch(authControllerProvider.notifier);
  return SignUpNotifier(authController);
});

class SignUpNotifier extends StateNotifier<SignUpState> {
  final AuthController _authController;

  SignUpNotifier(this._authController) : super(const SignUpState());

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmailPassword({
    required String userType,
    required BuildContext context,
  }) async {
    if (!state.isFormValid) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final (userTypeEnum, merchantType) = _parseUserType(userType);

      final result = await _authController.signUpWithEmailPassword(
        email: state.email.trim(),
        password: state.password,
        userType: userTypeEnum,
        merchantType: merchantType,
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
          context.go('/profile-setup?type=$userType');
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

  /// Sign up with Google
  Future<bool> signUpWithGoogle({
    required String userType,
    required BuildContext context,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final (userTypeEnum, merchantType) = _parseUserType(userType);

      final result = await _authController.signInWithGoogle(
        userType: userTypeEnum,
        merchantType: merchantType,
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
          context.go('/profile-setup?type=$userType');
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

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(
      confirmPassword: confirmPassword,
      errorMessage: null,
      isFormValid: _validateForm(state.email, state.password, confirmPassword),
    );
  }

  void updateEmail(String email) {
    state = state.copyWith(
      email: email,
      errorMessage: null,
      isFormValid: _validateForm(email, state.password, state.confirmPassword),
    );
  }

  void updatePassword(String password) {
    state = state.copyWith(
      password: password,
      errorMessage: null,
      isFormValid: _validateForm(state.email, password, state.confirmPassword),
    );
  }

  String? validateConfirmPassword() {
    if (state.confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (state.password != state.confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Form validation getters
  String? validateEmail() {
    if (state.email.isEmpty) {
      return 'Email is required';
    }
    if (!state.email.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword() {
    if (state.password.isEmpty) {
      return 'Password is required';
    }
    if (state.password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Parse user type string to enums
  (UserType, MerchantType?) _parseUserType(String userType) {
    switch (userType) {
      case 'agriShop':
        return (UserType.merchant, MerchantType.agriShop);
      case 'supermarketVendor':
        return (UserType.merchant, MerchantType.supermarketVendor);
      case 'farmer':
      default:
        return (UserType.farmer, null);
    }
  }

  bool _validateForm(String email, String password, String confirmPassword) {
    return email.isNotEmpty &&
        email.contains('@') &&
        password.length >= 6 &&
        password == confirmPassword;
  }
}

class SignUpState {
  final String email;
  final String password;
  final String confirmPassword;
  final bool isLoading;
  final String? errorMessage;
  final bool isFormValid;

  const SignUpState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.errorMessage,
    this.isFormValid = false,
  });

  SignUpState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    bool? isLoading,
    String? errorMessage,
    bool? isFormValid,
  }) {
    return SignUpState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}
