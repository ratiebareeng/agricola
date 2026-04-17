import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AgricolaCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'agricolaImageCache';
  static final AgricolaCacheManager _instance = AgricolaCacheManager._();
  factory AgricolaCacheManager() => _instance;

  AgricolaCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 500,
        ));
}

/// Precaches up to [limit] image URLs into the Flutter image cache.
/// Call from didChangeDependencies when a list first loads.
Future<void> precacheNetworkImages(
  BuildContext context,
  Iterable<String> urls, {
  int limit = 20,
}) async {
  for (final url in urls.where((u) => u.isNotEmpty).take(limit)) {
    if (!context.mounted) return;
    await precacheImage(
      CachedNetworkImageProvider(url, cacheManager: AgricolaCacheManager()),
      context,
    ).catchError((_) {});
  }
}
