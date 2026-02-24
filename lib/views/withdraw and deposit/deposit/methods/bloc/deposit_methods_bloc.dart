import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/CommonData/payment_method_model.dart';
import 'package:meta/meta.dart';

part 'deposit_methods_event.dart';
part 'deposit_methods_state.dart';

class DepositMethodsBloc extends Bloc<DepositMethodsEvent, DepositMethodsState> {
  DepositMethodsBloc() : super(DepositMethodsInitial()) {
    on<LoadDepositMethods>(_onLoadDepositMethods);
    on<RefreshDepositMethods>(_onRefreshDepositMethods);
  }

  FutureOr<void> _onLoadDepositMethods(
      LoadDepositMethods event,
      Emitter<DepositMethodsState> emit,
      ) async {
    emit(DepositMethodsLoading());

    try {
      final url = baseUrl + getActivePaymentMethods;

      final response = await dio.get(
        url,
        queryParameters: {'type': 'deposit'},
      );

      final methodsResponse =
      ActivePaymentMethodsResponse.fromJson(response.data);

      if (!methodsResponse.success) {
        emit(DepositMethodsError(
            message: 'Failed to load payment methods'));
        return;
      }

      // 🔥 Filter only active deposit methods
      final activeMethods = methodsResponse.data
          .where((method) => method.isDepositActive)
          .toList();

      if (activeMethods.isEmpty) {
        emit(DepositMethodsEmpty());
        return;
      }

      // 🔥 Custom Order Priority
      const orderPriority = {
        'usdt': 1,
        'usdt_bep20': 1,
        'upi': 2,
        'bitcoin': 3,
        'usdt_trc_20': 4,
        'usdt_erc_20': 5,
      };

      // 🔥 Sort according to required order
      activeMethods.sort((a, b) {
        final aPriority =
            orderPriority[a.paymentMode.toLowerCase()] ?? 999;
        final bPriority =
            orderPriority[b.paymentMode.toLowerCase()] ?? 999;

        return aPriority.compareTo(bPriority);
      });

      emit(DepositMethodsLoaded(methods: activeMethods));
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString() ??
          'Failed to load payment methods'
          : 'Failed to load payment methods';

      emit(DepositMethodsError(message: message));
    } catch (e) {
      emit(DepositMethodsError(
          message: 'Failed to load payment methods'));
    }
  }

  FutureOr<void> _onRefreshDepositMethods(RefreshDepositMethods event, Emitter<DepositMethodsState> emit) async {
    add(LoadDepositMethods());
  }
}
