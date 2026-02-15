/// Environment configuration for the Agricola app
///
/// Automatically uses:
/// - Development (localhost) for debug builds
/// - Production (Render) for release builds
///
/// You can override via environment variable:
/// flutter run --dart-define=ENVIRONMENT=production
library;

import 'package:flutter/foundation.dart';

final _developmentConfig = _DevelopmentConfig();

final _productionConfig = _ProductionConfig();

enum AppEnvironment { development, production }

class EnvironmentConfig {
  // Cold start handling configuration
  static const Duration coldStartTimeout = Duration(seconds: 60);

  static const int maxRetries = 3;

  static const Duration initialRetryDelay = Duration(seconds: 3);

  static const Duration serverWakeDelay = Duration(seconds: 5);
  // API Configuration
  static String get apiBaseUrl {
    switch (environment) {
      case AppEnvironment.development:
        return _developmentConfig.apiBaseUrl;
      case AppEnvironment.production:
        return _productionConfig.apiBaseUrl;
    }
  }

  static Duration get apiTimeout {
    switch (environment) {
      case AppEnvironment.development:
        return _developmentConfig.apiTimeout;
      case AppEnvironment.production:
        return _productionConfig.apiTimeout;
    }
  }

  // Automatically use production for release builds, development for debug
  static AppEnvironment get defaultEnvironment =>
      kReleaseMode ? AppEnvironment.production : AppEnvironment.development;

  static bool get enableLogging {
    switch (environment) {
      case AppEnvironment.development:
        return _developmentConfig.enableLogging;
      case AppEnvironment.production:
        return _productionConfig.enableLogging;
    }
  }

  // Use environment variable override, or default based on build mode
  static AppEnvironment get environment {
    const envString = String.fromEnvironment('ENVIRONMENT');
    if (envString.isNotEmpty) {
      return AppEnvironment.values.firstWhere(
        (e) => e.name == envString.toLowerCase(),
        orElse: () => defaultEnvironment,
      );
    }
    return defaultEnvironment;
  }

  static String get environmentName => environment.name;

  static bool get isDevelopment => environment == AppEnvironment.development;

  static bool get isProduction => environment == AppEnvironment.production;
}

// Development configuration
class _DevelopmentConfig {
  // For Android emulator: 10.0.2.2 maps to host machine's localhost
  // For iOS simulator: localhost works directly
  // For physical device: Set your machine's local IP (e.g., '192.168.1.100')
  static const String? localIpOverride = null;

  final Duration apiTimeout = const Duration(
    seconds: 45,
  ); // Match production for cold starts

  final bool enableLogging = true;
  String get apiBaseUrl {
    if (localIpOverride != null) {
      return 'http://$localIpOverride:8080';
    }
    // Default to localhost - will be overridden in ApiConstants for Android
    return 'http://localhost:8080';
  }
}

// Production configuration
class _ProductionConfig {
  final String apiBaseUrl = 'https://pandamatenga-api.onrender.com';
  final Duration apiTimeout = const Duration(
    seconds: 45,
  ); // Longer timeout for cold starts
  final bool enableLogging = false; // Disable verbose logging in production
}
