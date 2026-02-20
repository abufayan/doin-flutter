import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/datamodel/change_password_response.dart';
import 'package:doin_fx/datamodel/contact_response.dart';
import 'package:doin_fx/setup.dart';
import 'package:meta/meta.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {

  ContactData? _contactDataCache;


  ChangePasswordBloc() : super(ChangePasswordInitial()) {
    on<LoadData>(_loadContactInfo);
    on<ChangePasswordSubmitted>(_onChangePasswordSubmitted);
  }

  FutureOr<void> _onChangePasswordSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    // First check if passwords match
    if (event.newPassword != event.confirmPassword) {
      emit(
        PasswordMismatchError(
          message: 'New password and confirm password do not match',
        ),
      );
      return;
    }

    emit(ChangePasswordLoading());

    try {
      final userId = getIt<MyAccountService>().user?.userId;

      if (userId == null) {
        emit(ChangePasswordError(message: 'User ID not found'));
        return;
      }

      final data = {
        'user_id': userId,
        'oldPassword': event.oldPassword,
        'newPassword': event.newPassword,
        'confirmPassword': event.confirmPassword,
      };

      final response = await dio.post(baseUrl + changePassword, data: data);

      final result = ChangePasswordResponse.fromJson(response.data);

      if (result.isSuccess) {
        emit(ChangePasswordSuccess(message: result.message));
      } else {
        emit(ChangePasswordError(message: result.message));
      }
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? 'Failed to change password';
      emit(ChangePasswordError(message: message.toString()));
    } catch (e) {
      emit(ChangePasswordError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _loadContactInfo(
      LoadData event,
      Emitter<ChangePasswordState> emit,
      ) async {
    try {
      // emit(ChangePasswordLoading());
      final response = await dio.get(baseUrl + getContactInfo);
      final contactResponse = ContactResponse.fromJson(response.data);

      if (contactResponse.data.isNotEmpty) {
        _contactDataCache = contactResponse.data.first;

        emit(ChangePasswordLoaded(contactData: _contactDataCache!));

      }
    } catch (e) {
      // We don't necessarily want to emit error for the whole screen if just contact info fails
    }
  }
}
