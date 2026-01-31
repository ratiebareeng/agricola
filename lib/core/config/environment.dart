/// Environment configuration for the Agricola app
///
/// To switch environments, change the [currentEnvironment] value:
/// - AppEnvironment.development: Local development with localhost backend
/// - AppEnvironment.production: Production deployment on Render
///
/// You can also override via environment variable:
/// flutter run --dart-define=ENVIRONMENT=production
library;

final _developmentConfig = _DevelopmentConfig();

final _productionConfig = _ProductionConfig();

enum AppEnvironment { development, production }

class EnvironmentConfig {
  // CHANGE THIS TO SWITCH ENVIRONMENTS
  static const AppEnvironment currentEnvironment = AppEnvironment.development;

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

  static bool get enableLogging {
    switch (environment) {
      case AppEnvironment.development:
        return _developmentConfig.enableLogging;
      case AppEnvironment.production:
        return _productionConfig.enableLogging;
    }
  }

  // Or use environment variable override
  static AppEnvironment get environment {
    const envString = String.fromEnvironment('ENVIRONMENT');
    if (envString.isNotEmpty) {
      return AppEnvironment.values.firstWhere(
        (e) => e.name == envString.toLowerCase(),
        orElse: () => currentEnvironment,
      );
    }
    return currentEnvironment;
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

  final Duration apiTimeout = const Duration(seconds: 30);

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
