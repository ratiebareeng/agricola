import 'dart:io';

import 'package:agricola/features/profile/data/datasources/firebase_storage_service.dart';
import 'package:agricola/features/profile/data/datasources/profile_api_service.dart';
import 'package:agricola/features/profile/data/datasources/profile_cache_service.dart';
import 'package:agricola/features/profile/domain/failures/profile_failure.dart';
import 'package:agricola/features/profile/domain/models/profile_response.dart';
import 'package:agricola/features/profile/domain/repositories/profile_repository.dart';
import 'package:agricola/features/profile_setup/models/farmer_profile_model.dart';
import 'package:agricola/features/profile_setup/models/merchant_profile_model.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fpdart/fpdart.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApiService _apiService;
  final ProfileCacheService _cacheService;
  final FirebaseStorageService _storageService;

  ProfileRepositoryImpl({
    required ProfileApiService apiService,
    required ProfileCacheService cacheService,
    required FirebaseStorageService storageService,
  }) : _apiService = apiService,
       _cacheService = cacheService,
       _storageService = storageService;

  @override
  Future<Either<ProfileFailure, Unit>> clearCache() async {
    try {
      await _cacheService.clearCache();
      return right(unit);
    } catch (e) {
      return left(ProfileFailure.fromException(e));
    }
  }

  @override
  Future<Either<ProfileFailure, FarmerProfileModel>> createFarmerProfile({
    required FarmerProfileModel profile,
  }) async {
    try {
      final profileData = profile.toJson();
      final response = await _apiService.createFarmerProfile(profileData);

      // Extract the data field from the API response
      final data = response['data'] as Map<String, dynamic>;
      final createdProfile = FarmerProfileModel.fromJson(data);

      await _cacheService.cacheFarmerProfile(createdProfile);

      return right(createdProfile);
    } on DioException catch (e) {
      return left(_handleDioError(e));
    } catch (e) {
      return left(ProfileFailure.fromException(e));
    }
  }

  @override
  Future<Either<ProfileFailure, MerchantProfileModel>> createMerchantProfile({
    required MerchantProfileModel profile,
  }) async {
    try {
      final profileData = profile.toJson();
      final response = await _apiService.createMerchantProfile(profileData);

      // Extract the data field from the API response
      final data = response['data'] as Map<String, dynamic>;
      final createdProfile = MerchantProfileModel.fromJson(data);

      await _cacheService.cacheMerchantProfile(createdProfile);

      return right(createdProfile);
    } on DioException catch (e) {
      return left(_handleDioError(e));
    } catch (e) {
      return left(ProfileFailure.fromException(e));
    }
  }

  @override
  Future<Either<ProfileFailure, Unit>> deleteProfile({
    required String profileId,
  }) async {
    try {
      await _apiService.deleteProfile(profileId);

      await _cacheService.clearCache();

      return right(unit);
    } on DioException catch (e) {
      return left(_handleDioError(e));
    } catch (e) {
      return left(ProfileFailure.fromException(e));
    }
  }

  @override
  Future<Either<ProfileFailure, Unit>> deleteProfilePhoto({
    required String photoUrl,
  }) async {
    try {
      final userId = _extractUserIdFromPhotoUrl(photoUrl);
      await _storageService.deleteProfilePhoto(userId);
      return right(unit);
    } on FirebaseException {
      return right(unit);
    } catch (e) {
      return left(ProfileFailure.fromException(e));
    }
  }

  @override
  Future<Either<ProfileFailure, ProfileResponse>> getProfile({
    required String userId,
  }) async {
    final cachedProfile = _cacheService.getCachedProfile();
    if (cachedProfile != null && cachedProfile.userId == userId) {
      return right(cachedProfile);
    }

    try {
      try {
        final response = await _apiService.getFarmerProfile(userId);
        // Extract the data field from the API response
        final data = response['data'] as Map<String, dynamic>;
        final farmerProfile = FarmerProfileModel.fromJson(data);
        await _cacheService.cacheFarmerProfile(farmerProfile);
        return right(FarmerProfileResponse(farmerProfile));
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) {
          return left(_handleDioError(e));
        }
      }

      final response = await _apiService.getMerchantProfile(userId);
      // Extract the data field from the API response
      final data = response['data'] as Map<String, dynamic>;
      final merchantProfile = MerchantProfileModel.fromJson(data);
      await _cacheService.cacheMerchantProfile(merchantProfile);
      return right(MerchantProfileResponse(merchantProfile));
    } on DioException catch (e) {
      return left(_handleDioError(e));
    } catch (e) {
      return left(ProfileFailure.fromException(e));
    }
  }

  @override
  Future<Either<ProfileFailure, ProfileResponse>> refreshProfile({
    required String userId,
  }) async {
    try {
      try {
        final response = await _apiService.getFarmerProfile(userId);
        // Extract the data field from the API response
        final data = response['data'] as Map<String, dynamic>;
        final farmerProfile = FarmerProfileModel.fromJson(data);
        await _cacheService.cacheFarmerProfile(farmerProfile);
        return right(FarmerProfileResponse(farmerProfile));
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) {
          return left(_handleDioError(e));
        }
      }

      final response = await _apiService.getMerchantProfile(userId);
      // Extract the data field from the API response
      final data = response['data'] as Map<String, dynamic>;
      final merchantProfile = MerchantProfileModel.fromJson(data);
      await _cacheService.cacheMerchantProfile(merchantProfile);
      return right(MerchantProfileResponse(merchantProfile));
    } on DioException catch (e) {
      return left(_handleDioError(e));
    } catch (e) {
      return left(ProfileFailure.fromException(e));
    }
  }

  @override
  Future<Either<ProfileFailure, FarmerProfileModel>> updateFarmerProfile({
    required FarmerProfileModel profile,
  }) async {
    try {
      final updates = profile.toJson();
      final response = await _apiService.updateFarmerProfile(
        profile.id,
        updates,
      );

      // Extract the data field from the API response
      final data = response['data'] as Map<String, dynamic>;
      final updatedProfile = FarmerProfileModel.fromJson(data);

      await _cacheService.cacheFarmerProfile(updatedProfile);

      return right(updatedProfile);
    } on DioException catch (e) {
      return left(_handleDioError(e));
    } catch (e) {
      return left(ProfileFailure.fromException(e));
    }
  }

  @override
  Future<Either<ProfileFailure, MerchantProfileModel>> updateMerchantProfile({
    required MerchantProfileModel profile,
  }) async {
    try {
      final updates = profile.toJson();
      final response = await _apiService.updateMerchantProfile(
        profile.id,
        updates,
      );

      // Extract the data field from the API response
      final data = response['data'] as Map<String, dynamic>;
      final updatedProfile = MerchantProfileModel.fromJson(data);

      await _cacheService.cacheMerchantProfile(updatedProfile);

      return right(updatedProfile);
    } on DioException catch (e) {
      return left(_handleDioError(e));
    } catch (e) {
      return left(ProfileFailure.fromException(e));
    }
  }

  @override
  Future<Either<ProfileFailure, String>> uploadProfilePhoto({
    required File photoFile,
    required String userId,
  }) async {
    try {
      final photoUrl = await _storageService.uploadProfilePhoto(
        photoFile,
        userId,
      );

      return right(photoUrl);
    } on FirebaseException catch (e) {
      return left(
        ProfileFailure(
          message: 'Failed to upload photo: ${e.message}',
          type: ProfileFailureType.serverError,
          originalError: e,
        ),
      );
    } catch (e) {
      return left(ProfileFailure.fromException(e));
    }
  }

  String _extractUserIdFromPhotoUrl(String photoUrl) {
    final uri = Uri.parse(photoUrl);
    final pathSegments = uri.pathSegments;
    final profilesIndex = pathSegments.indexOf('profiles');

    if (profilesIndex != -1 && profilesIndex + 1 < pathSegments.length) {
      return pathSegments[profilesIndex + 1];
    }

    return '';
  }

  ProfileFailure _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ProfileFailure.networkError('Request timeout');
    }

    if (error.type == DioExceptionType.connectionError) {
      return ProfileFailure.networkError('No internet connection');
    }

    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (statusCode == 404) {
      return ProfileFailure.notFound('Profile not found');
    }

    if (statusCode == 401 || statusCode == 403) {
      return ProfileFailure.unauthorized('Unauthorized access');
    }

    if (statusCode == 400 && data is Map<String, dynamic>) {
      final message = data['message'] as String? ?? 'Invalid data';
      return ProfileFailure.invalidData(message);
    }

    if (statusCode != null && statusCode >= 500) {
      return ProfileFailure.serverError('Server error');
    }

    return ProfileFailure.fromException(error);
  }
}
