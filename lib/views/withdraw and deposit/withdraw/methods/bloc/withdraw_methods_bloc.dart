import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/CommonData/payment_method_model.dart';
import 'package:meta/meta.dart';

part 'withdraw_methods_event.dart';
part 'withdraw_methods_state.dart';

class WithdrawMethodsBloc extends Bloc<WithdrawMethodsEvent, WithdrawMethodsState> {
  WithdrawMethodsBloc() : super(WithdrawMethodsInitial()) {
    on<LoadWithdrawMethods>(_onLoadWithdrawMethods);
    on<RefreshWithdrawMethods>(_onRefreshWithdrawMethods);
  }

  FutureOr<void> _onLoadWithdrawMethods(LoadWithdrawMethods event, Emitter<WithdrawMethodsState> emit) async {
    emit(WithdrawMethodsLoading());

    try {
      final url = baseUrl + getActivePaymentMethods;
      final response = await dio.get(url, queryParameters: {'type': 'withdrawal'});

      final methodsResponse = ActivePaymentMethodsResponse.fromJson(response.data);

      if (!methodsResponse.success) {
        emit(WithdrawMethodsError(message: 'Failed to load withdrawal methods'));
        return;
      }

      // Filter only active withdrawal methods
      final activeMethods = methodsResponse.data.where((method) => method.isWithdrawalActive).toList();

      if (activeMethods.isEmpty) {
        emit(WithdrawMethodsEmpty());
      } else {
        emit(WithdrawMethodsLoaded(methods: activeMethods));
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString() ?? 'Failed to load withdrawal methods'
          : 'Failed to load withdrawal methods';
      emit(WithdrawMethodsError(message: message));
    } catch (e) {
      emit(WithdrawMethodsError(message: 'Failed to load withdrawal methods'));
    }
  }

  FutureOr<void> _onRefreshWithdrawMethods(RefreshWithdrawMethods event, Emitter<WithdrawMethodsState> emit) async {
    add(LoadWithdrawMethods());
  }
}
