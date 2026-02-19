import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/core/services/wallet_service.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/orders/datamodel/trade_order.dart';
import 'package:meta/meta.dart';

part 'pending_order_event.dart';
part 'pending_order_state.dart';

class PendingOrderBloc extends Bloc<PendingOrderEvent, PendingOrderState> {
  PendingOrderBloc() : super(PendingOrderInitial()) {
    on<PendingOrderEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<LoadPendingOrders>(loadPendingOrders);
  }

  Future<void> loadPendingOrders(
    LoadPendingOrders event,
    Emitter<PendingOrderState> emit,
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
        'status': 'pending',
      };

      final response = await dio.get(url, queryParameters: params);

      final parsed = OpenOrdersResponse.fromJson(response.data);

      if (parsed.status != 'success') {
        emit(Error(message: parsed.message));
        return;
      }
      emit(PendingOrdersLoaded(orders: parsed.data));

      // emit(_buildLoadedState(orders: parsed.data));
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? 'Failed to load pending orders';
      emit(Error(message: message.toString()));
    } catch (e) {
      emit(Error(message: 'Failed to load open orders'));
    }
  }
}
