// Add at bottom of crop_api_service.dart
import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/features/debug/data/health_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final healthServiceProvider = Provider<HealthService>((ref) {
  final dio = ref.watch(httpClientProvider);
  return HealthService(dio);
});
