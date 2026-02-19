import 'package:dio/dio.dart';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/interceptor.dart';
import 'package:doin_fx/core/routes/app_router.dart';

// const String baseUrl = 'http://localhost:5000/';
// test url

// String baseUrl = 'http://10.0.2.2:5000/';
AppType appType = AppType.Local;

String baseUrl = appType == AppType.Local ? 'http://192.168.1.42:5000/' : 'https://api.dointrade.com/';
// final baseUrl = getIt<MyAccountService>().isPhysicalDevice ? 'http://192.168.1.7:5000/' : 'http://10.0.2.2:5000/';

final AppRouter appRouter = AppRouter();

// Dio instance with authentication interceptor
final Dio dio = Dio(
  BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  ),
)..interceptors.add(AuthInterceptor());

// http://10.0.2.2:5000
