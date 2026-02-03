import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:dio/dio.dart';

class CropApiService {
  final Dio _dio;

  CropApiService(this._dio);

  /// POST /api/crops — create a new crop
  Future<CropModel> createCrop(CropModel crop) async {
    final response = await _dio.post('/api/crops', data: crop.toJson());
    return CropModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// GET /api/crops — get all crops for the authenticated user
  Future<List<CropModel>> getUserCrops() async {
    final response = await _dio.get('/api/crops');
    final list = response.data['data'] as List<dynamic>;
    return list.map((json) => CropModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// PUT /api/crops/<id> — update an existing crop
  Future<CropModel> updateCrop(String id, CropModel crop) async {
    final response = await _dio.put('/api/crops/$id', data: crop.toJson());
    return CropModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// DELETE /api/crops/<id> — delete a crop
  Future<void> deleteCrop(String id) async {
    await _dio.delete('/api/crops/$id');
  }
}
