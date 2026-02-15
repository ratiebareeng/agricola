import 'dart:async';
import 'dart:io';

import 'package:agricola/core/config/environment.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor that automatically retries failed requests due to cold starts.
/// Implements exponential backoff strategy for connection timeouts and network errors.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({
    required this.dio,
    int? maxRetries,
    Duration? initialDelay,
  })  : maxRetries = maxRetries ?? EnvironmentConfig.maxRetries,
        initialDelay = initialDelay ?? EnvironmentConfig.initialRetryDelay;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only retry on cold-start-related errors
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final requestOptions = err.requestOptions;
    final retryCount = requestOptions.extra['retryCount'] as int? ?? 0;

    if (retryCount >= maxRetries) {
      if (kDebugMode) {
        print('[RetryInterceptor] Max retries ($maxRetries) reached for ${requestOptions.path}');
      }
      return handler.next(err);
    }

    // Calculate delay with exponential backoff
    final delay = initialDelay * (1 << retryCount); // 2^retryCount
    
    if (kDebugMode) {
      print('[RetryInterceptor] Retry ${retryCount + 1}/$maxRetries for ${requestOptions.path} after ${delay.inSeconds}s');
      print('[RetryInterceptor] Error type: ${err.type}, message: ${err.message}');
    }

    // Wait before retrying
    await Future.delayed(delay);

    // Update retry count
    requestOptions.extra['retryCount'] = retryCount + 1;

    try {
      // Retry the request
      final response = await dio.fetch(requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      // If retry also fails, continue with error handling
      return handler.next(e);
    }
  }

  /// Check if error is likely due to cold start (server not ready)
  bool _shouldRetry(DioException err) {
    // Don't retry on client errors (4xx)
    if (err.response?.statusCode != null) {
      final statusCode = err.response!.statusCode!;
      if (statusCode >= 400 && statusCode < 500) {
        return false;
      }
    }

    // Retry on these error types (likely cold start related)
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return true;
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.unknown:
        // Check for socket exceptions which indicate server not ready
        if (err.error is SocketException) {
          return true;
        }
        return false;
      default:
        return false;
    }
  }
}

/// Extension to check if an error is cold-start related
extension ColdStartErrorExtension on DioException {
  bool get isColdStartError {
    // Check response status
    if (response?.statusCode != null) {
      final statusCode = response!.statusCode!;
      // 5xx errors or specific cold-start status codes
      if (statusCode >= 500 || statusCode == 503 || statusCode == 502) {
        return true;
      }
    }

    // Check error type
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.unknown:
        return error is SocketException;
      default:
        return false;
    }
  }
}
