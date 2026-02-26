import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/core/utils/logger.dart';
import 'package:doin_fx/setup.dart';
import 'package:meta/meta.dart';

part 'detail_pending_event.dart';
part 'detail_pending_state.dart';

class DetailPendingBloc extends Bloc<DetailPendingEvent, DetailPendingState> {
  DetailPendingBloc() : super(DetailPendingInitial()) {
    on<DetailPendingEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<UpdateTrade>(updateTrade);
    on<CloseTrade>(closeTrade);
    on<RemoveTpSl>(removeTpSl);
  }

  FutureOr<void> updateTrade(UpdateTrade event, Emitter<DetailPendingState> emit) async {
    emit(Loading());

    try {
      final params = {
        'user_id': getIt<MyAccountService>().user?.userId,
        // 'status': 'active',
      };
      Map<String, dynamic> data = {};

      data.addAll({'user_id': getIt<MyAccountService>().user?.userId.toString()});

      if (event.takeProfit != null) {
        data['take_profit'] = event.takeProfit!.toString();
      }

      if (event.stopLoss != null) {
        data['stop_loss'] = event.stopLoss!.toString();
      }

      final accountType = getIt<MyAccountService>().accountType;
      final baseUrlPath = accountType == AccountType.demo ? demoGetTrades : getTrades;

      final response = await dio.put(
        '$baseUrl$baseUrlPath/${event.tradeId}/tp-sl',
        // queryParameters: params,
        data: data,
      );

      final parsed = response.data;

      AppLogger.info('Pending trade update: $parsed', tag: 'API');

      if (parsed['status'] != 'success') {
        emit(UpdateTradeError(message: parsed['message'])); // ✅ Correct
        return;
      }
      emit(UpdateTradeSuccess(message: parsed['message'])); // ✅ Correct
    } on DioException catch (e) {
      emit(UpdateTradeError(message: e.response?.data['message']));
    } catch (e) {
      emit(UpdateTradeError(message: 'Unexpected error: $e'));
    }
  }

  FutureOr<void> closeTrade(CloseTrade event, Emitter<DetailPendingState> emit) async {
    emit(Loading());

    try {
      final body = {
        'user_id': getIt<MyAccountService>().user?.userId,
        // 'status': 'active',
      };

      final accountType = getIt<MyAccountService>().accountType;
      final baseUrlPath = accountType == AccountType.demo ? demoGetTrades : getTrades;

      final response = await dio.post(
        '$baseUrl$baseUrlPath/${event.tradeId}/close',
        // queryParameters: params,
        data: body,
      );

      // final parsed = OpenOrdersResponse.fromJson(response.data);

      final parsed = response.data;

      if (parsed['status'] != 'success') {
        emit(UpdateTradeError(message: parsed['message'])); // ✅ Correct
        return;
      }
      emit(TradeClosed(message: parsed['message'])); // ✅ Correct
    } on DioException catch (e) {
      emit(UpdateTradeError(message: 'Unable to close trade'));
    } catch (e) {
      emit(UpdateTradeError(message: 'Unexpected error: $e'));
    }
  }

  FutureOr<void> removeTpSl(RemoveTpSl event, Emitter<DetailPendingState> emit) async {
    try {
      final accountType = getIt<MyAccountService>().accountType;

      final removeUrl = accountType == AccountType.demo ? removeDemoTpSl : removeRealTpSl;

      Map<String, dynamic> data = {'user_id': getIt<MyAccountService>().user?.userId};

      if (event.removeTp) {
        data.addAll({'take_profit': null});
      }

      if (event.removeSl) {
        data.addAll({'stop_loss': null});
      }

      final response = await dio.put(baseUrl + removeUrl + '/${event.tradeId}/tp-sl', data: data);

      if (response.data['status'] != 'success') {
        emit(UpdateTradeError(message: response.data['message']));
        return;
      }

      emit(RemoveTpSlSuccess(message: response.data['message'], removedTp: event.removeTp, removedSl: event.removeSl));
    } on DioException catch (e) {
      String errorMessage = 'Something went wrong';

      if (e.response != null) {
        final data = e.response?.data;

        if (data is Map<String, dynamic>) {
          errorMessage = data['message'] ?? data['error'] ?? 'Request failed';
        } else {
          errorMessage = 'Server error (${e.response?.statusCode})';
        }
      }

      emit(UpdateTradeError(message: errorMessage));
    } catch (e) {
      emit(UpdateTradeError(message: 'Remove TP/SL failed: $e'));
    }
  }
}
