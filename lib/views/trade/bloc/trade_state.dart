// trade_state.dart

import 'package:doin_fx/datamodel/order_model.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class TradeState {}

final class TradeInitial extends TradeState {}
final class TradeLoading extends TradeState {}

// Action state for one-off events like showing SnackBars
@immutable
sealed class TradeActionState extends TradeState {}

final class TradeBuySuccess extends TradeActionState {
  final BuyOrderModel buyOrder;
  TradeBuySuccess({required this.buyOrder});
}

final class TradeSellSuccess extends TradeActionState {
  final SellOrderModel sellOrder;
  TradeSellSuccess({required this.sellOrder});
}

final class TradeBuyFailure extends TradeActionState {
  final String message;
  TradeBuyFailure({required this.message});
}
