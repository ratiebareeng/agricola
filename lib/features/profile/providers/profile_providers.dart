import 'package:agricola/core/network/http_client_provider.dart';
import 'package:agricola/features/profile/data/datasources/firebase_storage_service.dart';
import 'package:agricola/features/profile/data/datasources/profile_api_service.dart';
import 'package:agricola/features/profile/data/datasources/profile_cache_service.dart';
import 'package:agricola/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:agricola/features/profile/domain/repositories/profile_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Firebase Storage instance
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

/// Firebase Storage service
final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
  final storage = ref.watch(firebaseStorageProvider);
  return FirebaseStorageService(storage);
});

/// Profile API service
final profileApiServiceProvider = Provider<ProfileApiService>((ref) {
  final dio = ref.watch(httpClientProvider);
  return ProfileApiService(dio);
});

/// Profile cache service
final profileCacheServiceProvider = Provider<ProfileCacheService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProfileCacheService(prefs);
});

/// Profile repository (main interface)
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    apiService: ref.watch(profileApiServiceProvider),
    cacheService: ref.watch(profileCacheServiceProvider),
    storageService: ref.watch(firebaseStorageServiceProvider),
  );
});

/// SharedPreferences instance
/// Must be overridden in main.dart with actual instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});
