import 'package:dio/dio.dart';
import 'package:doin_fx/core/interceptor.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



// const String baseUrl = 'http://localhost:5000/';

const String baseUrl = 'http://10.0.2.2:5000/';

late final AppRouter appRouter  = AppRouter();

// Dio instance with authentication interceptor
late final Dio dio = Dio(
  BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ),
)..interceptors.add(AuthInterceptor());

// http://10.0.2.2:5000





