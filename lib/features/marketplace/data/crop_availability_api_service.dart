import 'package:agricola/core/constants/api_constants.dart';
import 'package:agricola/features/marketplace/models/crop_availability_model.dart';
import 'package:dio/dio.dart';

class CropAvailabilityApiService {
  final Dio _dio;

  CropAvailabilityApiService(this._dio);

  Future<CropAvailabilityData> getCropAvailability({
    String? cropType,
    int weeks = 8,
  }) async {
    final params = <String, dynamic>{'weeks': weeks};
    if (cropType != null) params['crop_type'] = cropType;

    final response = await _dio.get(
      '/${ApiConstants.cropAvailabilityEndpoint}',
      queryParameters: params,
    );

    final data = response.data['data'] as Map<String, dynamic>;

    final availableNow = (data['available_now'] as List<dynamic>? ?? [])
        .map((j) => AvailableNowItem.fromJson(j as Map<String, dynamic>))
        .toList();

    final upcoming = (data['upcoming'] as List<dynamic>? ?? [])
        .map((j) => UpcomingHarvestItem.fromJson(j as Map<String, dynamic>))
        .toList();

    final summary = (data['summary'] as List<dynamic>? ?? [])
        .map((j) => SupplyAggregate.fromJson(j as Map<String, dynamic>))
        .toList();

    return CropAvailabilityData(
      availableNow: availableNow,
      upcoming: upcoming,
      summary: summary,
    );
  }
}
