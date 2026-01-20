import 'package:dio/dio.dart';
import 'package:doin_fx/core/services/token_storage_service.dart';

/// Dio interceptor for handling authentication tokens and errors
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Get token from secure storage
    final token = await TokenStorageService.getToken();
    
    // Add token to request headers if available
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // Set content type
    options.headers['Content-Type'] = 'application/json';

    ///
    print(
      'options :'
      '''${options.uri}, 
${options.queryParameters.isNotEmpty ? options.queryParameters : ''}
${options.headers}
${options.data}
''',
    );
    
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('response : ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // print('response : ${err.response?.data}');
    // Handle 401 Unauthorized - token expired or invalid
    // print('response : ${err.response}');
    if (err.response?.statusCode == 401) {
      // Clear stored tokens
      await TokenStorageService.clearTokens();
      
      // Note: Navigation to login should be handled by the UI layer
      // when it detects the user is no longer authenticated.
      // You can listen to auth state changes or check token on app start.
    }
    
    handler.next(err);
  }
}
