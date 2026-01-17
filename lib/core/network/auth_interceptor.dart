import 'package:agricola/features/auth/providers/auth_token_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class AuthInterceptor extends Interceptor {
  final Ref _ref;

  AuthInterceptor(this._ref);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _handleUnauthorized(err);
    } else if (err.response?.statusCode == 403) {
      _handleForbidden(err);
    }

    handler.next(err);
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    
    if (_shouldSkipAuth(options.path)) {
      handler.next(options);
      return;
    }

    try {
      
      final token = await _ref.getAuthToken();

      
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      handler.next(options);
    } catch (e) {
      
      
      handler.next(options);
    }
  }

  
  void _handleForbidden(DioException err) {
    
    print('Access forbidden: ${err.message}');

    
    
  }

  
  void _handleUnauthorized(DioException err) {
    
    
    

    
    print('Auth token expired or invalid: ${err.message}');

    
    
  }

  
  bool _shouldSkipAuth(String path) {
    const unauthenticatedPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/health',
      '/public/',
    ];

    return unauthenticatedPaths.any((p) => path.startsWith(p));
  }
}
