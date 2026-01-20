// ignore_for_file: unused_local_variable, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, empty_catches, avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/core/services/token_storage_service.dart';
import 'package:doin_fx/datamodel/registered_data.dart';
import 'package:doin_fx/datamodel/user_model.dart';
import 'package:doin_fx/setup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  }

  FutureOr<void> _onLogin( 
  LoginSubmitted event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading(state.registerData));

  try {
    final url = Uri.parse(baseUrl + loginToApp);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': event.email,
        'password': event.password,
      }),
    );

    late Map<String, dynamic> data;
    data = jsonDecode(response.body) as Map<String, dynamic>;
    // print('Parsed Data: $data');

    // Check HTTP status code first
    if (response.statusCode != 200 && response.statusCode != 201) {


      String errorMessage = 'No Data';
      if(data['message'] == null || data['message'] == '') {
        errorMessage = data['error'];
      } else {
        errorMessage = data['message'];
      }
      

      emit(AuthFailure(
        error: data['error']?.toString() ?? 'Error',
        message: errorMessage,
        registerData: state.registerData
      ));
      return;
    }

    if (response.statusCode == 400) {
      emit(AuthFailure(
        error: data['error']?.toString() ?? 'Error',
        message: data['message']?.toString() ?? 'An error occurred',
        registerData: state.registerData
      ));
      return;
    }

    

    if(data['status'] == 'error') { 
      emit(AuthFailure(
        error: data['error']?.toString() ?? 'Error',
        message: data['message']?.toString() ?? 'An error occurred', 
        registerData: state.registerData
      ));
      return;
    }

    // Extract and store token from response
    // API Response: { "status": "success", "message": "...", "token": "...", "user": {...} }
    final token = data['token']?.toString();
    
    if (token != null && token.isNotEmpty) {
      await TokenStorageService.saveToken(token);
    } else {
      emit(AuthFailure(
        error: 'Authentication error', 
        message: 'Login successful but no token received', 
        registerData: state.registerData
      ));
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
      } catch (e, stackTrace) { 
        // Don't fail login if user data storage fails, but log it
      }
    }

    final message = data['message']?.toString() ?? 'Login successful';
    await getIt<MyAccountService>().initialize();
    emit(
      LoginSuccess(message, state.registerData),
    );
  } catch (e, stackTrace) {
    emit(AuthFailure(
      error: 'Login failed', 
      message: 'An error occurred during login: ${e.toString()}', 
      registerData: state.registerData
    ));
  }
}

  FutureOr<void> _onRegister(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading(state.registerData));
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final url = Uri.parse(baseUrl + sendEmailOtp);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': event.email,
          'username': event.name,
        }),
      );

      var data = jsonDecode(response.body);

      // if(data['error'] != '' && data['error'] != null) { 
      //   emit(AuthFailure(error: data['error'], message: data['message'])); 
      //   return;
      // } 
      if(data['status'] == 'success') {
        emit(OtpSentSuccessfully(data['message'], state.registerData.copyWith(username: event.name, email: event.email)));
      } else {
        emit(AuthFailure(error: data['error'], message: data['message'], registerData: state.registerData)); 
        return;
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString(), message: 'Server Error', registerData:  state.registerData), );
    }

    // emit(AuthSuccess('${event.email}', state.registerData));
  }

  FutureOr<void> _onOtp(OtpSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading(state.registerData));
    
    try {
      final url = Uri.parse(baseUrl + verifyEmailOtp);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': event.email,
          'otp': event.code,
        }),
      );


      var data = jsonDecode(response.body);
      
      if(data['status'] == 'success') {
        emit(AuthSuccess(data['message'], state.registerData));
      } else {
        emit(AuthFailure(error: data['error'], message: data['message'], registerData: state.registerData)); 
        return;
      }
    } catch (e) {}

  }

  FutureOr<void> _onForgotPassword(ForgotPasswordSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading(state.registerData));
    await Future.delayed(const Duration(milliseconds: 500));
    emit(AuthSuccess('Reset link sent to ${event.email}', state.registerData));
  }

  FutureOr<void> _passwordSubmitted(PasswordSubmitted event, Emitter<AuthState> emit) {
    // emit(AuthLoading(state.registerData));
    emit(AuthSuccess('Password Set Correctly', state.registerData.copyWith(
      password: event.password,
      confirmPassword: event.confirmPasssword
    )));
    
  }

  FutureOr<void> _whatsAppNumberSubmitted(WhatsAppNumberSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading(state.registerData));

    try {
      final url = Uri.parse(baseUrl + register);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({ 
          'email' : state.registerData.email,
          'username' : state.registerData.username,
          'password': state.registerData.password,
          'confirmPassword': state.registerData.password,
          'whatsapp_number' : event.whatsappNumber
        }),
      );

      var data = jsonDecode(response.body);
      
      if(data['status'] == 'success') {
        emit(UserRegisteredSuccessfully(data['message'] ?? 'Registration successful!', state.registerData));
      } else {
        String errorMessage = data['message'] ?? data['error'] ?? 'Registration failed';
        emit(AuthFailure(error: data['error'] ?? 'Unknown error', message: errorMessage, registerData: state.registerData)); 
        return;
      }
      
    } catch (error, stackTrace) {
      emit(AuthFailure(
        error: 'Registration Error', 
        message: 'An error occurred during registration: ${error.toString()}', 
        registerData: state.registerData
      ));
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
}
