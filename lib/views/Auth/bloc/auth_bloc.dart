// ignore_for_file: unused_local_variable, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, empty_catches, avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/Market/marketService.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/core/services/token_storage_service.dart';
import 'package:doin_fx/datamodel/registered_data.dart';
import 'package:doin_fx/datamodel/user_model.dart';
import 'package:doin_fx/core/utils/logger.dart';
import 'package:doin_fx/setup.dart';
import 'package:flutter/material.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginSubmitted>(_onLogin);
    on<RegisterSubmitted>(_onRegister);
    on<OtpSubmitted>(_onOtp);
    on<ForgotPasswordSubmitted>(_onForgotPassword);
    on<PasswordSubmitted>(_passwordSubmitted);
    on<WhatsAppNumberSubmitted>(_whatsAppNumberSubmitted);
    on<LogoutRequested>(_onLogout);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<ResetPasswordRequested>(_resetPasswordRequested);
  }

  FutureOr<void> _onLogin(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading(state.registerData));

    try {
      final url = Uri.parse(baseUrl + loginToApp);

      final response = await dio.post(
        baseUrl + loginToApp,
        // headers: {'Content-Type': 'application/json'},
        data: {'email': event.email, 'password': event.password},
      );
      // .timeout(const Duration(seconds: 10));

      // late Map<String, dynamic> data;
      final data = response.data as Map<String, dynamic>;

      // Check HTTP status code first
      if (response.statusCode != 200 && response.statusCode != 201) {
        String errorMessage = 'No Data';
        if (data['message'] == null || data['message'] == '') {
          errorMessage = data['error'];
        } else {
          errorMessage = data['message'];
        }

        emit(
          AuthFailure(
            error: data['error']?.toString() ?? 'Error',
            message: errorMessage,
            registerData: state.registerData,
          ),
        );
        return;
      }

      if (response.statusCode == 400) {
        emit(
          AuthFailure(
            error: data['error']?.toString() ?? 'Error',
            message: data['message']?.toString() ?? 'An error occurred',
            registerData: state.registerData,
          ),
        );
        return;
      }

      if (data['status'] == 'error') {
        emit(
          AuthFailure(
            error: data['error']?.toString() ?? 'Error',
            message: data['message']?.toString() ?? 'An error occurred',
            registerData: state.registerData,
          ),
        );
        return;
      }

      // Extract and store token from response
      // API Response: { "status": "success", "message": "...", "token": "...", "user": {...} }
      final token = data['token']?.toString();

      if (token != null && token.isNotEmpty) {
        await TokenStorageService.saveToken(token);
      } else {
        emit(
          AuthFailure(
            error: 'Authentication error',
            message: 'Login successful but no token received',
            registerData: state.registerData,
          ),
        );
        return;
      }

      // Save refresh token if available (not in current response, but keeping for future compatibility)
      final refreshToken = data['refreshToken']?.toString();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await TokenStorageService.saveRefreshToken(refreshToken);
      }

      // Extract and store user data from response
      if (data['user'] != null && data['user'] is Map) {
        try {
          final userData = data['user'] as Map<String, dynamic>;
          final user = UserModel.fromJson(userData);
          await TokenStorageService.saveUser(user);
        } catch (e) {
          // Don't fail login if user data storage fails, but log it
        }
      }

      final message = data['message']?.toString() ?? 'Login successful';

      await getIt<MyAccountService>().initialize();
      // await getIt<MarketPriceService>().connect();

      emit(LoginSuccess(message, state.registerData));
    } on DioException catch (e) {
      final data = e.response?.data;
      String errorMessage = 'Login failed';
      if (data is Map<String, dynamic>) {
        errorMessage = data['message'] ?? data['error'] ?? 'Login failed';
      }
      emit(AuthFailure(error: 'Login failed', message: errorMessage, registerData: state.registerData));
    }
  }

  FutureOr<void> _onRegister(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading(state.registerData));

    try {
      final response = await dio.post(baseUrl + sendEmailOtp, data: {'email': event.email, 'username': event.name});

      final data = response.data is String ? jsonDecode(response.data) : response.data;

      emit(OtpSentSuccessfully(data['message'], state.registerData.copyWith(username: event.name, email: event.email)));
    }
    // 🔥 THIS is where 400 errors come
    on DioException catch (e) {
      final data = e.response?.data;
      String errorMessage = 'Registration failed';
      if (data is Map<String, dynamic>) {
        errorMessage = data['message'] ?? data['error'] ?? 'Registration failed';
      }
      emit(AuthFailure(error: 'REQUEST_FAILED', message: errorMessage, registerData: state.registerData));
    }
    // 🔥 Truly unexpected errors
    catch (e) {
      emit(
        AuthFailure(
          error: 'UNKNOWN_ERROR',
          message: 'Something went wrong. Please try again.',
          registerData: state.registerData,
        ),
      );
    }
  }

  FutureOr<void> _onOtp(OtpSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading(state.registerData));

    try {
      final response = await dio.post(baseUrl + verifyEmailOtp, data: {'email': event.email, 'otp': event.code});

      final data = response.data is String ? jsonDecode(response.data) : response.data;

      emit(AuthSuccess(data['message'], state.registerData));
    } on DioException catch (e) {
      final data = e.response?.data;
      String errorMessage = 'OTP verification failed';
      if (data is Map<String, dynamic>) {
        errorMessage = data['message'] ?? data['error'] ?? 'OTP verification failed';
      }
      emit(AuthFailure(error: 'OTP_ERROR', message: errorMessage, registerData: state.registerData));
    } catch (e) {
      // 🔥 Any unexpected error
      emit(
        AuthFailure(
          error: 'UNKNOWN_ERROR',
          message: 'Something went wrong. Please try again.',
          registerData: state.registerData,
        ),
      );
    }
  }

  FutureOr<void> _onForgotPassword(ForgotPasswordSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading(state.registerData));

    try {
      String url = baseUrl;
      Map<String, dynamic> param = {};
      bool navigate = true;

      if (event.code == null) {
        url += forgotPassword;
        param.addAll({'email': event.email});
      } else {
        url += verifyForgotPasswordOtp;
        param.addAll({'email': event.email, 'otp': event.code});
        navigate = false;
      }
      final response = await dio.post(url, data: param);

      final data = response.data is String ? jsonDecode(response.data) : response.data;

      if (data['status'] == 'success') {
        emit(
          OtpForgotPasswordSuccess(
            state.registerData,
            message: data['message'],
            email: event.email,
            navigateRequired: navigate,
          ),
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      String errorMessage = 'Failed to process request';
      if (data is Map<String, dynamic>) {
        errorMessage = data['message'] ?? data['error'] ?? 'Failed to process request';
      }
      emit(OtpForgotPasswordError(state.registerData, message: errorMessage, email: event.email));
    }
  }

  FutureOr<void> _passwordSubmitted(PasswordSubmitted event, Emitter<AuthState> emit) {
    // emit(AuthLoading(state.registerData));
    emit(
      AuthSuccess(
        'Password Set Correctly',
        state.registerData.copyWith(password: event.password, confirmPassword: event.confirmPasssword),
      ),
    );
  }

  FutureOr<void> _whatsAppNumberSubmitted(WhatsAppNumberSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading(state.registerData));

    try {
      final url = baseUrl + register;

      final response = await dio.post(
        url,
        data: {
          'email': state.registerData.email,
          'username': state.registerData.username,
          'password': state.registerData.password,
          'confirmPassword': state.registerData.password,
          'whatsapp_number': event.whatsappNumber,
        },
      );

      var data = response.data;

      AppLogger.info('Registration response received', tag: 'API');

      if (data['status'] == 'success') {
        emit(UserRegisteredSuccessfully(data['message'] ?? 'Registration successful!', state.registerData));
      } else {
        String errorMessage = data['message'] ?? data['error'] ?? 'Registration failed';
        emit(
          AuthFailure(error: data['error'] ?? 'Unknown error', message: errorMessage, registerData: state.registerData),
        );
        return;
      }
    } catch (error) {
      emit(
        AuthFailure(
          error: 'Registration Error',
          message: 'An error occurred during registration: ${error.toString()}',
          registerData: state.registerData,
        ),
      );
    }
  }

  FutureOr<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    // Check if user has a valid token stored
    final isAuthenticated = await TokenStorageService.isAuthenticated();

    if (isAuthenticated) {
      // User is authenticated, restore their session
      final user = await TokenStorageService.getUser();
      emit(SessionRestored(state.registerData, user: user));
    } else {
      // No valid session found
      emit(AuthInitial());
    }
  }

  FutureOr<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    // Clear stored tokens and user data
    await TokenStorageService.clearTokens();

    // Clear any sensitive register data and emit initial state
    emit(AuthInitial());
  }

  FutureOr<void> _resetPasswordRequested(ResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading(state.registerData));

    try {
      final response = await dio.post(
        baseUrl + resetPassword,
        data: {'email': event.email, "password": event.password, 'confirmPassword': event.password},
      );

      final data = response.data is String ? jsonDecode(response.data) : response.data;

      if (data['status'] == 'success') {
        emit(PasswordResetSuccess(data['message'], state.registerData));
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      String errorMessage = 'Reset failed';
      if (data is Map<String, dynamic>) {
        errorMessage = data['message'] ?? data['error'] ?? 'Reset failed';
      }
      emit(AuthFailure(error: 'Reset failed', message: errorMessage, registerData: state.registerData));
    }
  }
}
