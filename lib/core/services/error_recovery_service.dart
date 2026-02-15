import 'dart:async';
import 'dart:io';

import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/core/network/interceptors/retry_interceptor.dart';
import 'package:agricola/core/services/server_wake_service.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Service for handling errors with user-friendly recovery options.
/// Provides context-aware error messages and retry functionality.
class ErrorRecoveryService {
  /// Execute an operation with automatic retry and user feedback
  static Future<T> executeWithRetry<T>({
    required Future<T> Function() operation,
    required BuildContext context,
    String? errorMessage,
    String? successMessage,
    int maxRetries = 3,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        final result = await operation();

        if (successMessage != null && context.mounted) {
          _showSuccessSnackbar(context, successMessage);
        }

        return result;
      } catch (error) {
        attempts++;

        if (!isColdStartError(error) || attempts >= maxRetries) {
          if (context.mounted) {
            _showErrorSnackbar(
              context,
              errorMessage ?? _getErrorMessage(error),
              onRetry: attempts < maxRetries
                  ? () async {
                      // Let the caller handle retry
                    }
                  : null,
            );
          }
          rethrow;
        }

        // Show warming up message for cold start errors
        if (context.mounted) {
          _showInfoSnackbar(
            context,
            'Server is starting up... (attempt $attempts/$maxRetries)',
          );
        }

        // Wait before retrying
        await Future.delayed(Duration(seconds: 3 * attempts));
      }
    }

    throw Exception('Operation failed after $maxRetries attempts');
  }

  /// Check if an error is likely due to server cold start
  static bool isColdStartError(Object error) {
    if (error is DioException) {
      return error.isColdStartError;
    }

    if (error is SocketException) {
      return true;
    }

    if (error is TimeoutException) {
      return true;
    }

    // Check error message for common cold start indicators
    final message = error.toString().toLowerCase();
    return message.contains('timeout') ||
        message.contains('connection') ||
        message.contains('socket') ||
        message.contains('host lookup');
  }

  /// Show a cold start specific message with wake-up option
  static void showColdStartSnackbar(
    BuildContext context, {
    VoidCallback? onWakeUp,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Server is starting up. This may take a moment...'),
        backgroundColor: AppColors.earthBrown,
        duration: const Duration(seconds: 15),
        action: onWakeUp != null
            ? SnackBarAction(
                label: 'Wake Up',
                textColor: AppColors.white,
                onPressed: () async {
                  final success = await ServerWakeService.forceWake();
                  if (context.mounted) {
                    if (success) {
                      _showSuccessSnackbar(context, 'Server is ready!');
                      onWakeUp();
                    } else {
                      _showErrorSnackbar(
                        context,
                        'Could not reach server. Please try again later.',
                      );
                    }
                  }
                },
              )
            : null,
      ),
    );
  }

  /// Show a snackbar with retry functionality
  static void showRetrySnackbar(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.earthBrown,
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'Retry',
          textColor: AppColors.white,
          onPressed: onRetry,
        ),
      ),
    );
  }

  /// Get a user-friendly error message
  static String _getErrorMessage(Object error) {
    if (error is DioException) {
      if (error.isColdStartError) {
        return 'Server is starting up. Please wait...';
      }
      return error.friendlyMessage;
    }

    if (error is SocketException) {
      return 'Unable to connect to server. Please check your internet connection.';
    }

    if (error is TimeoutException) {
      return 'Request timed out. The server might be starting up...';
    }

    return 'An unexpected error occurred. Please try again.';
  }

  static void _showErrorSnackbar(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.alertRed,
        duration: Duration(seconds: onRetry != null ? 10 : 4),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: AppColors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  static void _showInfoSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.earthBrown,
        duration: const Duration(seconds: 30),
      ),
    );
  }

  static void _showSuccessSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
