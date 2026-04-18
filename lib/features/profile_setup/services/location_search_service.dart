import 'package:agricola/features/profile_setup/services/botswana_locations.dart';
import 'package:dio/dio.dart';

class LocationSearchService {
  static final _dio = Dio(
    BaseOptions(
      baseUrl: 'https://nominatim.openstreetmap.org',
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {
        'User-Agent': 'agricola-app/1.0 (developer@agricola-app.com)',
        'Accept-Language': 'en',
      },
    ),
  );

  /// Search combining instant local matches and Nominatim for 4+ char queries.
  static Future<List<LocationSuggestion>> search(String query) async {
    final localNames = BotswanaLocations.search(query);
    final results = localNames
        .map((name) => LocationSuggestion(
              shortName: name,
              displayName: name,
              lat: 0,
              lon: 0,
            ))
        .toList();

    // Only hit the network for longer queries to avoid noisy results.
    if (query.trim().length >= 4) {
      try {
        final remote = await _searchNominatim(query)
            .timeout(const Duration(seconds: 4));
        final seen = results.map((s) => s.shortName.toLowerCase()).toSet();
        for (final r in remote) {
          if (seen.add(r.shortName.toLowerCase())) {
            results.add(r);
          }
        }
      } catch (_) {
        // Nominatim failure is non-critical — local results are shown.
      }
    }

    return results.take(8).toList();
  }

  static Future<List<LocationSuggestion>> _searchNominatim(
      String query) async {
    final response = await _dio.get<List<dynamic>>(
      '/search',
      queryParameters: {
        'q': query,
        'countrycodes': 'bw',
        'format': 'json',
        'limit': 8,
        'addressdetails': 1,
      },
    );

    final items = response.data ?? [];
    final seen = <String>{};
    final suggestions = <LocationSuggestion>[];

    for (final item in items) {
      final address = (item['address'] as Map<String, dynamic>?) ?? {};
      final shortName = _shortName(
        address,
        item['name'] as String?,
        item['display_name'] as String,
      );
      if (seen.add(shortName)) {
        suggestions.add(
          LocationSuggestion(
            shortName: shortName,
            displayName: item['display_name'] as String,
            lat: double.parse(item['lat'] as String),
            lon: double.parse(item['lon'] as String),
          ),
        );
      }
    }
    return suggestions;
  }

  static String _shortName(
    Map<String, dynamic> addr,
    String? name,
    String displayName,
  ) {
    return addr['village'] as String? ??
        addr['hamlet'] as String? ??
        addr['suburb'] as String? ??
        addr['neighbourhood'] as String? ??
        addr['town'] as String? ??
        addr['city'] as String? ??
        addr['municipality'] as String? ??
        name ??
        displayName.split(',').first.trim();
  }
}

class LocationSuggestion {
  final String shortName;
  final String displayName;
  final double lat;
  final double lon;

  const LocationSuggestion({
    required this.shortName,
    required this.displayName,
    required this.lat,
    required this.lon,
  });
}
