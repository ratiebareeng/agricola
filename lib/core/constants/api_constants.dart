import 'dart:io';

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
  static const Duration requestTimeout = Duration(seconds: 30);

  static const Duration connectionTimeout = Duration(seconds: 15);

  // Set this to your machine's local IP address if testing on physical device
  // Find your IP: ifconfig | grep "inet " | grep -v 127.0.0.1
  static const String? _localIpOverride = null; // e.g., '192.168.1.100'

  static String get baseUrl {
    // If testing on physical device, use the local IP
    if (_localIpOverride != null) {
      return 'http://$_localIpOverride:8080';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    } else if (Platform.isIOS) {
      return 'http://localhost:8080';
    } else {
      return 'http://localhost:8080';
    }
  }
}
