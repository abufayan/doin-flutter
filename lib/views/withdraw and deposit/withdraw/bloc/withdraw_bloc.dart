import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/CommonData/minimum_values_model.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/withdraw/datamodel/withdraw_response_model.dart';
import 'package:meta/meta.dart';

part 'withdraw_event.dart';
part 'withdraw_state.dart';

class WithdrawBloc extends Bloc<WithdrawEvent, WithdrawState> {
  WithdrawBloc() : super(WithdrawInitial()) {
    on<LoadInitialValues>(loadInitialValues);
    on<OnWithdraw>(onSubmit);
  }
}

FutureOr<void> onSubmit(OnWithdraw event, Emitter<WithdrawState> emit) async {
  emit(WithdrawLoading());

  try {
    // Get user info from MyAccountService
    final accountService = getIt<MyAccountService>();
    final user = accountService.user;

    if (user == null) {
      emit(WithdrawFailure(message: 'User information not available', error: 'Please login again'));
      return;
    }

    // Validate required fields
    if (event.paymentScreenshot == null) {
      emit(
        WithdrawFailure(
          message: 'Payment screenshot is required',
          error: 'Column \'payment_screenshot\' cannot be null',
        ),
      );
      return;
    }

    if (event.paymentAddress.isEmpty) {
      emit(WithdrawFailure(message: 'Transaction ID is required', error: 'transaction_id cannot be empty'));
      return;
    }

    if (event.requestedAmount.isEmpty) {
      emit(WithdrawFailure(message: 'Amount is required', error: 'enter_amount cannot be empty'));
      return;
    }

    // Determine payment type
    // final String paymentType =
    // event.paymentMethod.toLowerCase() == 'upi' ? 'upi' : 'usdt';

    // Prepare form data with file
    final formData = FormData.fromMap({
      'user_id': user.userId,
      'username': user.username,
      'email': user.email,
      'payment_method': event.paymentMethod,
      'requested_amount_usd': event.requestedAmount,
      'transfer_amount_usd': event.requestedAmount,
      'payment_address_upi_id': event.paymentAddress,
      'qr_payment_screenshot': await MultipartFile.fromFile(
        event.paymentScreenshot!.path,
        filename: event.paymentScreenshot!.path.split('/').last,
      ),
    });

    // Make API call
    final response = await dio.post(withdrawal, data: formData);

    // Parse response
    final withdrawResponse = WithdrawApiResponse.fromJson(response.data as Map<String, dynamic>);

    if (withdrawResponse.isSuccess) {
      emit(WithdrawSuccess(response: withdrawResponse));
    } else {
      emit(WithdrawFailure(message: withdrawResponse.message, error: withdrawResponse.error));
    }
  } on DioException catch (e) {
    final message = e.response?.data['message'] ?? 'Withdrawal failed';
    emit(WithdrawFailure(message: message.toString(), error: e.toString()));
  } catch (e) {
    emit(WithdrawFailure(message: 'An unexpected error occurred', error: e.toString()));
  }
}

FutureOr<void> loadInitialValues(LoadInitialValues event, Emitter<WithdrawState> emit) async {
  emit(WithdrawLoading());

  try {
    final response = await dio.get(baseUrl + getMinimummDepsitValues);

    final minimumValues = PaymentConfigResponse.fromJson(response.data);

    if (minimumValues.success) {
      emit(WithDrawLoaded(minimumValues: minimumValues));
      return;
    }
  } on DioException catch (e) {
    final message = e.response?.data['message'] ?? 'Failed to load config';
    emit(WithdrawFailure(message: message.toString(), error: e.toString()));
  } catch (e) {
    emit(WithdrawFailure(message: 'An unexpected error occurred', error: e.toString()));
  }
}
