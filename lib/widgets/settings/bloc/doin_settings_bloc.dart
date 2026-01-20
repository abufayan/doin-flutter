import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/services/token_storage_service.dart';
import 'package:doin_fx/setup.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

part 'doin_settings_event.dart';
part 'doin_settings_state.dart';

class DoinSettingsBloc extends Bloc<DoinSettingsEvent, DoinSettingsState> {
  DoinSettingsBloc() : super(DoinSettingsInitial()) {
    on<LogoutEvent>(_onLogout);
  }

  FutureOr<void> _onLogout(
    LogoutEvent event,
    Emitter<DoinSettingsState> emit,
  ) async {
    emit(DoinSettingsLoading());

    try {
      // Call logout API - token is automatically added by interceptor
      final response = await dio.post(logOut);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        if (data['status'] == 'success' || data['status'] == 'Success') {
          // Clear tokens from storage
          await TokenStorageService.clearTokens();

          // Emit success state
          emit(LoggedOutSuccessfully());
        } else {
          // Even if API fails, clear local tokens
          await TokenStorageService.clearTokens();
          emit(LoggedOutSuccessfully());
        }
      } else {
        // Even if API fails, clear local tokens
        await TokenStorageService.clearTokens();
        emit(LoggedOutSuccessfully());
      }
    } on DioException catch (e) {
      // Even if API call fails, clear local tokens and logout
      await TokenStorageService.clearTokens();
      emit(LoggedOutSuccessfully());
    } catch (e) {
      // Even if there's an error, clear local tokens
      await TokenStorageService.clearTokens();
      emit(LoggedOutSuccessfully());
    }
  }
}
