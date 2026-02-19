import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/core/services/wallet_service.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/orders/datamodel/trade_order.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'closed_orders_event.dart';
part 'closed_orders_state.dart';

class ClosedOrdersBloc extends Bloc<ClosedOrdersEvent, ClosedOrdersState> {
  ClosedOrdersBloc() : super(ClosedOrdersInitial()) {
    on<ClosedOrdersEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<LoadClosedOrders>(loadClosedOrders);
  }

  Future<void> loadClosedOrders(
    LoadClosedOrders event,
    Emitter<ClosedOrdersState> emit,
  ) async {
    emit(Loading());

    await WalletService.updateAccountService();

    try {
      final accountType = getIt<MyAccountService>().accountType;
      final url = accountType == AccountType.demo
          ? baseUrl + demoGetTrades
          : baseUrl + getTrades;

      final params = {
        'user_id': getIt<MyAccountService>().user?.userId,
        'status': 'completed_cancelled_24_hr',
      };

      final response = await dio.get(url, queryParameters: params);

      final parsed = OpenOrdersResponse.fromJson(response.data);

      if (parsed.status != 'success') {
        emit(Error(message: parsed.message));
        return;
      }
      emit(ClosedOrdersLoaded(orders: parsed.data)); 

      // emit(_buildLoadedState(orders: parsed.data));
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? 'Failed to load closed orders';
      emit(Error(message: message.toString()));
    } catch (e) {
      emit(Error(message: 'Failed to load open orders'));
    }
  }
}
