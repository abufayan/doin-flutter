// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/datamodel/order_model.dart';
import 'package:doin_fx/setup.dart';
import 'package:flutter/material.dart';
import 'trade_event.dart';
import 'trade_state.dart';

class TradeBloc extends Bloc<TradeEvent, TradeState> {
  TradeBloc() : super(TradeInitial()) {
    on<LoadTrade>((event, emit) {});
    on<TradeBuyPressed>(tradeBuyPressed);
    on<TradeSellPressed>(tradeSellPressed);
  }

  FutureOr<void> tradeBuyPressed(
    TradeBuyPressed event,
    Emitter<TradeState> emit,
  ) async {
    try {
      final updated = Map<String, dynamic>.from(event.data ?? {});

      updated.addAll({
        'type' : 'BUY',
        'user_id': getIt<MyAccountService>()!.user?.userId.toString(),
      });

      var response = await dio.post(baseUrl + placeOrder, data: updated);

      final _buyOrder = BuyOrderModel.fromJson(response.data);
      print('orderStatus : ${_buyOrder.status}');

      if (_buyOrder.status == "success") {
        emit(TradeBuySuccess(buyOrder: _buyOrder));
      } else {
        emit(TradeBuyFailure(message: _buyOrder.message!));
      }
    }
    on DioException catch (e) {
    /// 🔥 THIS is where the real API message lives
    final serverMessage =
        e.response?.data is Map<String, dynamic>
            ? e.response?.data['message']?.toString()
            : null;

    emit(
      TradeBuyFailure(
        message: serverMessage ?? 'Something went wrong',
      ),
    );

    debugPrint('Dio error: ${e.response?.data}');
  } 
    catch (e) {
      emit(TradeBuyFailure(message: e.toString()));
      // print(e.toString());
    }
  }

  FutureOr<void> tradeSellPressed(
    TradeSellPressed event, // ✅ CORRECT
    Emitter<TradeState> emit,
  ) async  {

    try {
      final updated = Map<String, dynamic>.from(event.data ?? {});

      updated.addAll({
        'type' : 'SELL',
        'user_id': getIt<MyAccountService>()!.user?.userId.toString(),
      });

      var response = await dio.post(baseUrl + placeOrder, data: updated);

      final _sellOrder = SellOrderModel.fromJson(response.data);
      print('orderStatus : ${_sellOrder.status}');

      if (_sellOrder.status == "success") {
        emit(TradeSellSuccess(sellOrder: _sellOrder));
      } else {
        emit(TradeBuyFailure(message: _sellOrder.message!));
      }
    }
    on DioException catch (e) {
    /// 🔥 THIS is where the real API message lives
    final serverMessage =
        e.response?.data is Map<String, dynamic>
            ? e.response?.data['message']?.toString()
            : null;

    emit(
      TradeBuyFailure(
        message: serverMessage ?? 'Something went wrong',
      ),
    );

    debugPrint('Dio error: ${e.response?.data}');
  } 
    catch (e) {
      emit(TradeBuyFailure(message: e.toString()));
      // print(e.toString());
    }
    
  }
}
