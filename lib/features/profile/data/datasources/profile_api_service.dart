import 'package:agricola/core/network/http_client_provider.dart';
import 'package:dio/dio.dart';

class ProfileApiEndpoints {
  static const String basePath = '/api/profiles';
  static const String farmerPath = '$basePath/farmer';
  static const String merchantPath = '$basePath/merchant';

  static String deleteProfile(String profileId) => '$basePath/$profileId';
  static String getFarmerProfile(String userId) => '$farmerPath/$userId';
  static String getMerchantProfile(String userId) => '$merchantPath/$userId';
  static String updateFarmerProfile(String profileId) =>
      '$farmerPath/$profileId';
  static String updateMerchantProfile(String profileId) =>
      '$merchantPath/$profileId';
}

class ProfileApiService extends BaseApiService {
  final Dio _dio;

  ProfileApiService(super.dio) : _dio = dio;

  Future<Map<String, dynamic>> createFarmerProfile(
    Map<String, dynamic> profileData,
  ) async {
    final response = await _dio.post(
      ProfileApiEndpoints.farmerPath,
      data: profileData,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createMerchantProfile(
    Map<String, dynamic> profileData,
  ) async {
    final response = await _dio.post(
      ProfileApiEndpoints.merchantPath,
      data: profileData,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteProfile(String profileId) async {
    await _dio.delete(ProfileApiEndpoints.deleteProfile(profileId));
  }

  Future<Map<String, dynamic>> getFarmerProfile(String userId) async {
    final response = await _dio.get(
      ProfileApiEndpoints.getFarmerProfile(userId),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMerchantProfile(String userId) async {
    final response = await _dio.get(
      ProfileApiEndpoints.getMerchantProfile(userId),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateFarmerProfile(
    String profileId,
    Map<String, dynamic> updates,
  ) async {
    final response = await _dio.put(
      ProfileApiEndpoints.updateFarmerProfile(profileId),
      data: updates,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateMerchantProfile(
    String profileId,
    Map<String, dynamic> updates,
  ) async {
    final response = await _dio.put(
      ProfileApiEndpoints.updateMerchantProfile(profileId),
      data: updates,
    );
    return response.data as Map<String, dynamic>;
  }
}
