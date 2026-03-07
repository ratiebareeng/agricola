import 'package:agricola/core/constants/api_constants.dart';
import 'package:agricola/features/loss_calculator/models/loss_calculation.dart';
import 'package:dio/dio.dart';

class LossCalculatorApiService {
  final Dio _dio;

  LossCalculatorApiService(this._dio);

  Future<List<LossCalculation>> getCalculations() async {
    final response =
        await _dio.get('/${ApiConstants.lossCalculatorEndpoint}');
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((json) => LossCalculation.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<LossCalculation> getCalculation(String id) async {
    final response =
        await _dio.get('/${ApiConstants.lossCalculatorEndpoint}/$id');
    return LossCalculation.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<LossCalculation> saveCalculation(LossCalculation calculation) async {
    final response = await _dio.post(
      '/${ApiConstants.lossCalculatorEndpoint}',
      data: calculation.toJson(),
    );
    return LossCalculation.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteCalculation(String id) async {
    await _dio.delete('/${ApiConstants.lossCalculatorEndpoint}/$id');
  }
}
