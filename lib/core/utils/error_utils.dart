import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

/// Maps exceptions to translation keys for user-friendly bilingual error messages.
/// Returns a key that can be passed to `t(key, lang)` for translation.
String errorKeyFromException(Object e) {
  if (e is DioException) return _dioErrorKey(e);
  if (e is SocketException) return 'error_no_connection';
  if (e is TimeoutException) return 'error_timeout';
  return 'error_unexpected';
}

String _dioErrorKey(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
      return 'error_timeout';
    case DioExceptionType.receiveTimeout:
      return 'error_server_slow';
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode;
      if (code == 401) return 'error_auth_required';
      if (code == 403) return 'error_permission_denied';
      if (code == 404) return 'error_not_found';
      if (code == 409) return 'error_conflict';
      if (code != null && code >= 500) return 'error_server';
      return 'error_request_failed';
    case DioExceptionType.cancel:
      return 'error_cancelled';
    case DioExceptionType.connectionError:
    case DioExceptionType.unknown:
      return 'error_no_connection';
    default:
      return 'error_unexpected';
  }
}
