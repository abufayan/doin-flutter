import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/deposit/datamodel/deposit_response_model.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/CommonData/minimum_values_model.dart';
import 'package:meta/meta.dart';

part 'deposit_event.dart';
part 'deposit_state.dart';

class DepositBloc extends Bloc<DepositEvent, DepositState> {
  DepositBloc() : super(DepositInitial()) {
    on<LoadInitialValues>(loadInitialValues);
    on<OnSubmit>(onSubmit);
  }

  FutureOr<void> onSubmit(OnSubmit event, Emitter<DepositState> emit) async {
    emit(DepositLoading());

    try {
      // Get user info from MyAccountService
      final accountService = getIt<MyAccountService>();
      final user = accountService.user;

      if (user == null) {
        emit(DepositFailure(message: 'User information not available', error: 'Please login again'));
        return;
      }

      // Validate required fields
      if (event.paymentScreenshot == null) {
        emit(
          DepositFailure(
            message: 'Payment screenshot is required',
            error: 'Column \'payment_screenshot\' cannot be null',
          ),
        );
        return;
      }

      if (event.transactionId.isEmpty) {
        emit(DepositFailure(message: 'Transaction ID is required', error: 'transaction_id cannot be empty'));
        return;
      }

      if (event.enterAmount.isEmpty) {
        emit(DepositFailure(message: 'Amount is required', error: 'enter_amount cannot be empty'));
        return;
      }

      // Determine payment type
      final String paymentType = event.paymentMethod.toLowerCase() == 'upi' ? 'upi' : 'usdt';

      // Prepare form data with file
      final formData = FormData.fromMap({
        'user_id': user.userId,
        'username': user.username,
        'email': user.email,
        'payment_method': paymentType,
        'transaction_id': event.transactionId,
        'enter_amount': event.enterAmount,
        if (event.upiId != null && event.upiId!.isNotEmpty) 'upi_id': event.upiId,
        'payment_screenshot': await MultipartFile.fromFile(
          event.paymentScreenshot!.path,
          filename: event.paymentScreenshot!.path.split('/').last,
        ),
      });

      // Make API call
      final response = await dio.post(depositAmount, data: formData);

      // Parse response
      final depositResponse = DepositResponseModel.fromJson(response.data as Map<String, dynamic>);

      if (depositResponse.isSuccess) {
        emit(DepositSuccess(response: depositResponse));
      } else {
        emit(DepositFailure(message: depositResponse.message, error: depositResponse.error));
      }
    } on DioException catch (e) {
      final message = (e.response?.data is Map)
          ? e.response?.data['message']?.toString() ?? 'Deposit failed'
          : 'Deposit failed';
      emit(DepositFailure(message: message, error: e.toString()));
    } catch (e) {
      emit(DepositFailure(message: 'An unexpected error occurred', error: e.toString()));
    }
  }

  FutureOr<void> loadInitialValues(LoadInitialValues event, Emitter<DepositState> emit) async {
    emit(DepositLoading());

    try {
      final response = await dio.get(baseUrl + getMinimummDepsitValues);

      final minimumValues = PaymentConfigResponse.fromJson(response.data);

      if (minimumValues.success) {
        emit(DepositLoaded(minimumValues: minimumValues));
        return;
      }
    } on DioException catch (e) {
      final message = (e.response?.data is Map)
          ? e.response?.data['message']?.toString() ?? 'Failed to load values'
          : 'Failed to load values';
      emit(DepositFailure(message: message, error: e.toString()));
    } catch (e) {
      emit(DepositFailure(message: 'An unexpected error occurred', error: e.toString()));
    }
  }
}
