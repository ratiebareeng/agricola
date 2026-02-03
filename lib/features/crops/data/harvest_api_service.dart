import 'package:agricola/features/crops/models/harvest_model.dart';
import 'package:dio/dio.dart';

class HarvestApiService {
  final Dio _dio;

  HarvestApiService(this._dio);

  /// POST /api/harvests — record a new harvest
  Future<HarvestModel> createHarvest(HarvestModel harvest) async {
    final response = await _dio.post('/api/harvests', data: harvest.toJson());
    return HarvestModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// GET /api/harvests/crop/<cropId> — get all harvests for a crop
  Future<List<HarvestModel>> getHarvestsByCrop(String cropId) async {
    final response = await _dio.get('/api/harvests/crop/$cropId');
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((json) => HarvestModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// DELETE /api/harvests/<harvestId> — delete a harvest record
  Future<void> deleteHarvest(String harvestId) async {
    await _dio.delete('/api/harvests/$harvestId');
  }
}
