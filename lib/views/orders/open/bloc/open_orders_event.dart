part of 'open_orders_bloc.dart';

@immutable
sealed class OpenOrdersEvent {}

class LoadOpenOrders extends OpenOrdersEvent {
  final bool showLoading;
  LoadOpenOrders({this.showLoading = true});
}

class PriceUpdated extends OpenOrdersEvent {
  final PriceTick tick;

  PriceUpdated(this.tick);
}

final class UpdateTrade extends OpenOrdersEvent {
  final double? takeProfit;
  final double? stopLoss;
  final String tradeId;

  UpdateTrade({required this.takeProfit, required this.stopLoss, required this.tradeId});
}

final class RemoveTpSl extends OpenOrdersEvent {
  final String tradeId;
  final bool removeTp;
  final bool removeSl;

  RemoveTpSl({required this.tradeId, this.removeTp = false, this.removeSl = false});
}

final class CloseTrade extends OpenOrdersEvent {
  final String tradeId;

  CloseTrade({required this.tradeId});
}

class CloseAllTrades extends OpenOrdersEvent {}

class CloseAllProfitTrades extends OpenOrdersEvent {}

class CloseAllLossTrades extends OpenOrdersEvent {}

/// Event to reset TP/SL edit values to original
// class ResetEditValues extends OpenOrdersEvent {
//   final double? originalTakeProfit;
//   final double? originalStopLoss;
  
//   ResetEditValues({
//     this.originalTakeProfit,
//     this.originalStopLoss,
//   });
// }