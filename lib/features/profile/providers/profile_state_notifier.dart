import 'dart:io';

import 'package:agricola/features/auth/providers/auth_controller.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/profile/domain/failures/profile_failure.dart';
import 'package:agricola/features/profile/domain/models/displayable_profile.dart';
import 'package:agricola/features/profile/domain/models/profile_response.dart';
import 'package:agricola/features/profile/domain/repositories/profile_repository.dart';
import 'package:agricola/features/profile_setup/models/farmer_profile_model.dart';
import 'package:agricola/features/profile_setup/models/merchant_profile_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState extends Equatable {
  final DisplayableProfile? displayableProfile;
  final bool hasPostgresProfile;
  final bool isLoading;
  final String? errorMessage;
  final double? uploadProgress;

  const ProfileState({
    this.displayableProfile,
    this.hasPostgresProfile = false,
    this.isLoading = false,
    this.errorMessage,
    this.uploadProgress,
  });

  // Backward compatibility: return ProfileResponse from displayableProfile
  ProfileResponse? get profile {
    final profile = displayableProfile;
    if (profile == null) return null;

    return switch (profile) {
      CompleteFarmerProfile(farmerData: final farmerData) =>
        FarmerProfileResponse(farmerData),
      CompleteMerchantProfile(merchantData: final merchantData) =>
        MerchantProfileResponse(merchantData),
      MinimalProfile() => null, // No PostgreSQL profile yet
    };
  }

  // Convenience getters
  bool get hasMinimalProfile => displayableProfile is MinimalProfile;
  bool get needsProfileCompletion => !hasPostgresProfile;

  @override
  List<Object?> get props => [
        displayableProfile,
        hasPostgresProfile,
        isLoading,
        errorMessage,
        uploadProgress,
      ];

  ProfileState clearError() {
    return copyWith(errorMessage: '');
  }

  ProfileState copyWith({
    DisplayableProfile? displayableProfile,
    bool? hasPostgresProfile,
    bool? isLoading,
    String? errorMessage,
    double? uploadProgress,
  }) {
    return ProfileState(
      displayableProfile: displayableProfile ?? this.displayableProfile,
      hasPostgresProfile: hasPostgresProfile ?? this.hasPostgresProfile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  ProfileState setLoading(bool loading) {
    return copyWith(isLoading: loading, errorMessage: '');
  }
}

class ProfileStateNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;
  final AuthController _authController;
  final Ref _ref;

  ProfileStateNotifier({
    required ProfileRepository repository,
    required AuthController authController,
    required Ref ref,
  }) : _repository = repository,
       _authController = authController,
       _ref = ref,
       super(const ProfileState());

  void clearError() {
    state = state.clearError();
  }

  Future<void> clearProfile() async {
    await _repository.clearCache();
    state = const ProfileState();
  }

  Future<bool> createFarmerProfile({
    required FarmerProfileModel profile,
  }) async {
    state = state.setLoading(true);

    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const ProfileState(errorMessage: 'User not authenticated');
      return false;
    }

    final result = await _repository.createFarmerProfile(profile: profile);

    return result.fold(
      (failure) {
        state = ProfileState(errorMessage: failure.message);
        return false;
      },
      (createdProfile) async {
        final displayableProfile = CompleteFarmerProfile.fromModels(
          user: currentUser,
          profile: createdProfile,
        );
        state = ProfileState(
          displayableProfile: displayableProfile,
          hasPostgresProfile: true,
        );
        // Mark profile as complete and refresh user data
        await _authController.markProfileAsComplete();
        await _authController.refreshUserData();
        // Invalidate auth state to force reload with updated isProfileComplete
        _ref.invalidate(authStateProvider);
        // Wait a moment for the stream to update
        await Future.delayed(const Duration(milliseconds: 500));
        return true;
      },
    );
  }

  Future<bool> createMerchantProfile({
    required MerchantProfileModel profile,
  }) async {
    state = state.setLoading(true);

    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const ProfileState(errorMessage: 'User not authenticated');
      return false;
    }

    final result = await _repository.createMerchantProfile(profile: profile);

    return result.fold(
      (failure) {
        state = ProfileState(errorMessage: failure.message);
        return false;
      },
      (createdProfile) async {
        final displayableProfile = CompleteMerchantProfile.fromModels(
          user: currentUser,
          profile: createdProfile,
        );
        state = ProfileState(
          displayableProfile: displayableProfile,
          hasPostgresProfile: true,
        );
        // Mark profile as complete and refresh user data
        await _authController.markProfileAsComplete();
        await _authController.refreshUserData();
        // Invalidate auth state to force reload with updated isProfileComplete
        _ref.invalidate(authStateProvider);
        // Wait a moment for the stream to update
        await Future.delayed(const Duration(milliseconds: 500));
        return true;
      },
    );
  }

  Future<bool> deleteProfile({required String profileId}) async {
    state = state.setLoading(true);

    final result = await _repository.deleteProfile(profileId: profileId);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = const ProfileState();
        return true;
      },
    );
  }

  Future<bool> deleteProfilePhoto({required String photoUrl}) async {
    final result = await _repository.deleteProfilePhoto(photoUrl: photoUrl);

    return result.fold((failure) {
      state = state.copyWith(errorMessage: failure.message);
      return false;
    }, (_) => true);
  }

  Future<bool> loadProfile({
    required String userId,
    bool forceRefresh = false,
  }) async {
    state = state.setLoading(true);

    // Get current user from Firestore (always available)
    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const ProfileState(errorMessage: 'User not authenticated');
      return false;
    }

    // Try to load PostgreSQL profile
    final result = forceRefresh
        ? await _repository.refreshProfile(userId: userId)
        : await _repository.getProfile(userId: userId);

    return result.fold(
      (failure) {
        // If profile not found (404) or server error related to missing profile,
        // create minimal profile from Firestore
        final isProfileNotFound = failure.type == ProfileFailureType.notFound ||
            (failure.type == ProfileFailureType.serverError &&
                (failure.message.contains('does not exist') ||
                    failure.message.contains('not found')));

        if (isProfileNotFound) {
          final minimalProfile = MinimalProfile.fromUserModel(currentUser);
          state = ProfileState(
            displayableProfile: minimalProfile,
            hasPostgresProfile: false,
          );
          return true; // Success - we have a displayable profile
        }

        // Other errors (network, connection, etc.)
        state = ProfileState(errorMessage: failure.message);
        return false;
      },
      (profileResponse) {
        // Combine Firestore + PostgreSQL data
        final displayableProfile = switch (profileResponse) {
          FarmerProfileResponse(profile: final farmerProfile) =>
            CompleteFarmerProfile.fromModels(
              user: currentUser,
              profile: farmerProfile,
            ),
          MerchantProfileResponse(profile: final merchantProfile) =>
            CompleteMerchantProfile.fromModels(
              user: currentUser,
              profile: merchantProfile,
            ),
        };

        state = ProfileState(
          displayableProfile: displayableProfile,
          hasPostgresProfile: true,
        );
        return true;
      },
    );
  }

  Future<void> refreshProfile(String userId) async {
    await loadProfile(userId: userId, forceRefresh: true);
  }

  Future<bool> updateFarmerProfile({
    required FarmerProfileModel profile,
  }) async {
    state = state.setLoading(true);

    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const ProfileState(errorMessage: 'User not authenticated');
      return false;
    }

    final result = await _repository.updateFarmerProfile(profile: profile);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (updatedProfile) {
        final displayableProfile = CompleteFarmerProfile.fromModels(
          user: currentUser,
          profile: updatedProfile,
        );
        state = ProfileState(
          displayableProfile: displayableProfile,
          hasPostgresProfile: true,
        );
        return true;
      },
    );
  }

  /// Update farmer profile with photo upload if needed
  Future<String?> updateFarmerProfileWithPhoto({
    required FarmerProfileModel profile,
    File? newPhoto,
  }) async {
    state = state.setLoading(true);

    String? photoUrl = profile.photoUrl;

    if (newPhoto != null) {
      photoUrl = await uploadProfilePhoto(
        userId: profile.userId,
        photoFile: newPhoto,
      );

      if (photoUrl == null) {
        return 'Failed to upload photo';
      }
    }

    final updatedProfile = profile.copyWith(photoUrl: photoUrl);
    final success = await updateFarmerProfile(profile: updatedProfile);

    return success ? null : (state.errorMessage ?? 'Failed to update profile');
  }

  Future<bool> updateMerchantProfile({
    required MerchantProfileModel profile,
  }) async {
    state = state.setLoading(true);

    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const ProfileState(errorMessage: 'User not authenticated');
      return false;
    }

    final result = await _repository.updateMerchantProfile(profile: profile);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (updatedProfile) {
        final displayableProfile = CompleteMerchantProfile.fromModels(
          user: currentUser,
          profile: updatedProfile,
        );
        state = ProfileState(
          displayableProfile: displayableProfile,
          hasPostgresProfile: true,
        );
        return true;
      },
    );
  }

  /// Update merchant profile with photo upload if needed
  Future<String?> updateMerchantProfileWithPhoto({
    required MerchantProfileModel profile,
    File? newPhoto,
  }) async {
    state = state.setLoading(true);

    String? photoUrl = profile.photoUrl;

    if (newPhoto != null) {
      photoUrl = await uploadProfilePhoto(
        userId: profile.userId,
        photoFile: newPhoto,
      );

      if (photoUrl == null) {
        return 'Failed to upload photo';
      }
    }

    final updatedProfile = profile.copyWith(photoUrl: photoUrl);
    final success = await updateMerchantProfile(profile: updatedProfile);

    return success ? null : (state.errorMessage ?? 'Failed to update profile');
  }

  Future<String?> uploadProfilePhoto({
    required String userId,
    required File photoFile,
  }) async {
    state = state.copyWith(uploadProgress: 0.0);

    final result = await _repository.uploadProfilePhoto(
      userId: userId,
      photoFile: photoFile,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          uploadProgress: null,
          errorMessage: failure.message,
        );
        return null;
      },
      (photoUrl) {
        state = state.copyWith(uploadProgress: null);
        return photoUrl;
      },
    );
  }
}
