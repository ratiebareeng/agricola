import 'package:dio/dio.dart' show Dio;

class HealthService {
  final Dio _dio;
  HealthService(this._dio);

  Future<bool> getHealthStatus() async {
    try {
      final response = await _dio.get('/health');
      if (response.statusCode == 200) {
        final data = response.data;
        return data['status'] == 'harvest';
      } else {
        throw Exception('Failed to fetch health status');
      }
    } on Exception catch (e) {
      print(e);
      // TODO: Project wide error handling
      rethrow;
    }
  }
}
