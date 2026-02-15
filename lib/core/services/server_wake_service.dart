import 'package:agricola/core/config/environment.dart';
import 'package:agricola/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Service for proactively waking up idle servers.
/// Uses the health check endpoint to verify server status and warm up
/// backends running on free tiers (e.g., Render).
class ServerWakeService {
  static Dio? _dio;
  static bool _isWaking = false;
  static DateTime? _lastWakeTime;

  /// Initialize the Dio client for health checks
  static Dio get _client {
    _dio ??= Dio(
      BaseOptions(
        connectTimeout: EnvironmentConfig.coldStartTimeout,
        receiveTimeout: EnvironmentConfig.coldStartTimeout,
      ),
    );
    return _dio!;
  }

  /// Ensure the server is awake and ready to receive requests.
  /// Returns true if server is ready, false if wake-up failed.
  ///
  /// This method implements multiple wake-up strategies:
  /// 1. Quick check if server was recently woken
  /// 2. Single health endpoint hit
  /// 3. Retry with exponential backoff if needed
  static Future<bool> ensureServerAwake() async {
    // Skip if we recently woke the server (within last 5 minutes)
    if (_lastWakeTime != null) {
      final timeSinceLastWake = DateTime.now().difference(_lastWakeTime!);
      if (timeSinceLastWake.inMinutes < 5) {
        if (kDebugMode) {
          print('[ServerWakeService] Server recently woken, skipping wake-up');
        }
        return true;
      }
    }

    // Prevent concurrent wake-up attempts
    if (_isWaking) {
      if (kDebugMode) {
        print('[ServerWakeService] Wake-up already in progress, waiting...');
      }
      // Wait for existing wake-up to complete
      while (_isWaking) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      return _lastWakeTime != null;
    }

    _isWaking = true;

    try {
      final success = await _wakeWithRetry();
      if (success) {
        _lastWakeTime = DateTime.now();
      }
      return success;
    } finally {
      _isWaking = false;
    }
  }

  /// Force an immediate server check, bypassing the recent wake cache
  static Future<bool> forceWake() async {
    _lastWakeTime = null;
    return ensureServerAwake();
  }

  /// Check if the server is currently reachable
  static Future<bool> isServerAwake() async {
    try {
      final response = await _client.get(
        ApiConstants.healthUrl,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Reset the wake state (useful for testing or forcing a new wake-up)
  static void reset() {
    _lastWakeTime = null;
    _isWaking = false;
  }

  /// Wake the server with retry logic
  static Future<bool> _wakeWithRetry() async {
    final maxRetries = EnvironmentConfig.maxRetries;
    final initialDelay = EnvironmentConfig.initialRetryDelay;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      if (attempt > 0) {
        final delay = initialDelay * (1 << (attempt - 1));
        if (kDebugMode) {
          print(
            '[ServerWakeService] Retry attempt $attempt/$maxRetries after ${delay.inSeconds}s',
          );
        }
        await Future.delayed(delay);
      }

      try {
        if (kDebugMode) {
          print(
            '[ServerWakeService] Attempting to wake server at ${ApiConstants.healthUrl}',
          );
        }

        final response = await _client.get(ApiConstants.healthUrl);

        if (response.statusCode == 200) {
          if (kDebugMode) {
            print(
              '[ServerWakeService] Server is awake! Response: ${response.data}',
            );
          }
          return true;
        }
      } on DioException catch (e) {
        if (kDebugMode) {
          print(
            '[ServerWakeService] Wake attempt $attempt failed: ${e.type} - ${e.message}',
          );
        }

        // Continue to next retry unless it's a definitive failure
        if (e.response?.statusCode != null &&
            e.response!.statusCode! >= 400 &&
            e.response!.statusCode! < 500) {
          // Don't retry on 4xx errors
          if (kDebugMode) {
            print(
              '[ServerWakeService] Received ${e.response!.statusCode}, not retrying',
            );
          }
          return false;
        }
      } catch (e) {
        if (kDebugMode) {
          print('[ServerWakeService] Wake attempt $attempt error: $e');
        }
      }
    }

    if (kDebugMode) {
      print(
        '[ServerWakeService] Failed to wake server after $maxRetries retries',
      );
    }
    return false;
  }
}

/// Server wake status for UI display
enum ServerWakeStatus { checking, waking, ready, failed }
