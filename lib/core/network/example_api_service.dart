import 'package:agricola/core/network/http_client_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for crop API service
final cropApiServiceProvider = Provider<CropApiService>((ref) {
  final dio = ref.watch(httpClientProvider);
  return CropApiService(dio);
});

/// Example provider for user crops with automatic auth
final userCropsProvider = FutureProvider<List<CropModel>>((ref) async {
  final apiService = ref.watch(cropApiServiceProvider);
  return await apiService.getUserCrops();
});

/// Crop API service with automatic auth token injection
class CropApiService extends BaseApiService {
  CropApiService(super.dio);

  /// Create new crop - automatically includes auth token
  Future<CropModel> createCrop(CropModel crop) async {
    return await post(
      '/crops',
      data: crop.toJson(),
      fromJson: CropModel.fromJson,
    );
  }

  /// Delete crop - automatically includes auth token
  Future<void> deleteCrop(String id) async {
    await delete('/crops/$id');
  }

  /// Get user's crops - automatically includes auth token
  Future<List<CropModel>> getUserCrops() async {
    return await getList('/crops', fromJson: CropModel.fromJson);
  }

  /// Update crop - automatically includes auth token
  Future<CropModel> updateCrop(String id, CropModel crop) async {
    return await put(
      '/crops/$id',
      data: crop.toJson(),
      fromJson: CropModel.fromJson,
    );
  }
}

/// Example API service demonstrating auth integration
/// TODO: Replace with actual crop model when available
class CropModel {
  final String id;
  final String name;
  final String userId;

  CropModel({required this.id, required this.name, required this.userId});

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'],
      name: json['name'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'userId': userId};
  }
}

/// Usage example in a widget:
/// 
/// class CropsScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final cropsAsync = ref.watch(userCropsProvider);
///     
///     return cropsAsync.when(
///       data: (crops) => ListView.builder(
///         itemCount: crops.length,
///         itemBuilder: (context, index) => ListTile(
///           title: Text(crops[index].name),
///         ),
///       ),
///       loading: () => CircularProgressIndicator(),
///       error: (error, _) => Text('Error: $error'),
///     );
///   }
/// }