import 'package:agricola/core/constants/api_constants.dart';
import 'package:agricola/features/reports/models/analytics_model.dart';
import 'package:dio/dio.dart';

class AnalyticsApiService {
  final Dio _dio;

  AnalyticsApiService(this._dio);

  /// GET /api/v1/analytics?period=month|week|year|all
  Future<AnalyticsModel> getAnalytics({String period = 'month'}) async {
    final response = await _dio.get(
      '/${ApiConstants.analyticsEndpoint}',
      queryParameters: {'period': period},
    );
    return AnalyticsModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
