import 'dart:io';

import 'package:agricola/core/config/environment.dart';

class ApiConstants {
  static const String apiVersion = 'v1';

  // API doesn't currently use versioning prefix
  static const String apiPrefix = 'api/$apiVersion';
  static const String cropEndpoint = '$apiPrefix/crops';

  static const String profilesEndpoint = '$apiPrefix/profiles';
  static const String analyticsEndpoint = '$apiPrefix/analytics';
  static const String inventoryEndpoint = '$apiPrefix/inventory';
  static const String marketplaceEndpoint = '$apiPrefix/marketplace';
  static const String harvestsEndpoint = '$apiPrefix/harvests';

  // Timeout configuration from environment
  static Duration get requestTimeout => EnvironmentConfig.apiTimeout;
  static const Duration connectionTimeout = Duration(seconds: 15);

  /// Get the base URL based on current environment
  ///
  /// - Production: Uses Render backend (https://pandamatenga-api.onrender.com)
  /// - Development: Uses local backend with platform-specific URLs
  ///   - Android Emulator: http://10.0.2.2:8080 (maps to host's localhost)
  ///   - iOS Simulator: http://localhost:8080
  ///   - Physical Device: Set localIpOverride in environment.dart
  static String get baseUrl {
    if (EnvironmentConfig.isProduction) {
      // Production: Use Render backend
      return EnvironmentConfig.apiBaseUrl;
    }

    // Development: Platform-specific local URLs
    final devUrl = EnvironmentConfig.apiBaseUrl;

    // Override for Android emulator to use host machine's localhost
    if (Platform.isAndroid && devUrl.contains('localhost')) {
      return devUrl.replaceAll('localhost', '10.0.2.2');
    }

    return devUrl;
  }

  /// Health check endpoint
  static String get healthEndpoint => '/health';

  /// Full health check URL
  static String get healthUrl => '$baseUrl$healthEndpoint';
}
