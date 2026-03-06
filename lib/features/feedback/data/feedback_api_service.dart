import 'package:agricola/core/constants/api_constants.dart';
import 'package:dio/dio.dart';

class FeedbackApiService {
  final Dio _dio;

  FeedbackApiService(this._dio);

  Future<void> submitFeedback({
    required String feedbackText,
    String? screenshotBase64,
    String? deviceInfo,
  }) async {
    await _dio.post(
      '/${ApiConstants.feedbackEndpoint}',
      data: {
        'feedbackText': feedbackText,
        'screenshotBase64': screenshotBase64,
        'deviceInfo': deviceInfo,
      },
    );
  }
}
