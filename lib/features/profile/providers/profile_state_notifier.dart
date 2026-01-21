import 'dart:io';

import 'package:agricola/features/auth/providers/auth_controller.dart';
import 'package:agricola/features/profile/domain/models/profile_response.dart';
import 'package:agricola/features/profile/domain/repositories/profile_repository.dart';
import 'package:agricola/features/profile_setup/models/farmer_profile_model.dart';
import 'package:agricola/features/profile_setup/models/merchant_profile_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState extends Equatable {
  final ProfileResponse? profile;
  final bool isLoading;
  final String? errorMessage;
  final double? uploadProgress;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
    this.uploadProgress,
  });

  @override
  List<Object?> get props => [profile, isLoading, errorMessage, uploadProgress];

  ProfileState clearError() {
    return copyWith(errorMessage: '');
  }

  ProfileState copyWith({
    ProfileResponse? profile,
    bool? isLoading,
    String? errorMessage,
    double? uploadProgress,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
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

  ProfileStateNotifier({
    required ProfileRepository repository,
    required AuthController authController,
  }) : _repository = repository,
       _authController = authController,
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

    final result = await _repository.createFarmerProfile(profile: profile);

    return result.fold(
      (failure) {
        state = ProfileState(errorMessage: failure.message);
        return false;
      },
      (createdProfile) async {
        state = ProfileState(profile: FarmerProfileResponse(createdProfile));
        await _authController.markProfileAsComplete();
        return true;
      },
    );
  }

  Future<bool> createMerchantProfile({
    required MerchantProfileModel profile,
  }) async {
    state = state.setLoading(true);

    final result = await _repository.createMerchantProfile(profile: profile);

    return result.fold(
      (failure) {
        state = ProfileState(errorMessage: failure.message);
        return false;
      },
      (createdProfile) async {
        state = ProfileState(profile: MerchantProfileResponse(createdProfile));
        await _authController.markProfileAsComplete();
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

    final result = forceRefresh
        ? await _repository.refreshProfile(userId: userId)
        : await _repository.getProfile(userId: userId);

    return result.fold(
      (failure) {
        state = ProfileState(errorMessage: failure.message);
        return false;
      },
      (profileResponse) {
        state = ProfileState(profile: profileResponse);
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

    final result = await _repository.updateFarmerProfile(profile: profile);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (updatedProfile) {
        state = ProfileState(profile: FarmerProfileResponse(updatedProfile));
        return true;
      },
    );
  }

  Future<bool> updateMerchantProfile({
    required MerchantProfileModel profile,
  }) async {
    state = state.setLoading(true);

    final result = await _repository.updateMerchantProfile(profile: profile);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (updatedProfile) {
        state = ProfileState(profile: MerchantProfileResponse(updatedProfile));
        return true;
      },
    );
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
