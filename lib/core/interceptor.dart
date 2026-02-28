import 'package:dio/dio.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:doin_fx/core/services/token_storage_service.dart';
import 'package:doin_fx/core/utils/logger.dart';
import 'package:doin_fx/setup.dart';

/// Dio interceptor for handling authentication tokens and errors
class AuthInterceptor extends Interceptor {
  static bool _isLoggingOut = false;

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

    // Log request
    print('options.uri: ${options.uri}');
    print('options.headers: ${options.headers}');
    print('options.data: ${options.data}');


    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('Response data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // AppLogger.apiError(
    //   err.requestOptions.method,
    //   err.requestOptions.uri.toString(),
    //   err.response?.statusCode,
    //   error: err.message,
    //   stackTrace: err.stackTrace,
    // );

    print('Error occurred: ${err.message}');
    print('Error response data: ${err.response?.data}');

    final response = err.response;

    final bool isSessionExpired =
        response?.statusCode == 401 ||
        (response?.data is Map &&
            response?.data['message']?.toString().toLowerCase().contains('session expired') == true);

    if (isSessionExpired && !_isLoggingOut) {
      _isLoggingOut = true;

      try {
        AppLogger.auth('Session expired - clearing tokens and redirecting to login');
        await TokenStorageService.clearTokens();
        // SocketManager.instance.disconnect();
        appRouter.replaceAll([const LoginOrRegisterRoute()]);
      } catch (e, st) {
        AppLogger.error('Failed to handle session expiration', exception: e, stackTrace: st);
      } finally {
        _isLoggingOut = false;
      }

      return; // ⛔ intentionally NO handler.next
    }

    handler.next(err); // ✅ forward all other errors
  }
}
