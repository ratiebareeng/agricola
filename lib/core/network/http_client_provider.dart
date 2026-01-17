import 'package:agricola/core/network/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides configured Dio instance with auth interceptor
final httpClientProvider = Provider<Dio>((ref) {
  final dio = Dio();

  // Base configuration
  dio.options.baseUrl =
      'https://api.agricola.app'; // TODO: Update with actual backend URL
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);
  dio.options.headers['Content-Type'] = 'application/json';

  // Add auth interceptor
  dio.interceptors.add(AuthInterceptor(ref));

  // Add logging interceptor in debug mode
  if (const bool.fromEnvironment('dart.vm.product') == false) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ),
    );
  }

  return dio;
});

/// Extension for easy error handling
extension DioErrorExtension on DioException {
  String get friendlyMessage {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        if (response?.statusCode == 401) {
          return 'Authentication required. Please sign in again.';
        } else if (response?.statusCode == 403) {
          return 'You don\'t have permission for this action.';
        } else if (response?.statusCode == 404) {
          return 'The requested resource was not found.';
        } else if (response?.statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return 'Request failed with status ${response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.unknown:
        return 'Network error. Please check your internet connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}

/// Base API service class for common HTTP operations
abstract class BaseApiService {
  final Dio _dio;

  BaseApiService(this._dio);

  /// GET request with error handling
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET request for list with error handling
  Future<List<T>> getList<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);

      final List<dynamic> data = response.data;
      return data.map((json) => fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request with error handling
  Future<T> post<T>(
    String path, {
    dynamic data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request with error handling
  Future<T> put<T>(
    String path, {
    dynamic data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request with error handling
  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Common error handling
  String _handleError(DioException error) {
    return error.friendlyMessage;
  }
}
