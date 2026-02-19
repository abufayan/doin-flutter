part of 'detail_pending_bloc.dart';

@immutable
sealed class DetailPendingEvent {}

final class UpdateTrade extends DetailPendingEvent {
  final double? takeProfit;
  final double? stopLoss;
  final String tradeId;

  UpdateTrade({
    required this.takeProfit,
    required this.stopLoss,
    required this.tradeId
  });
}

final class CloseTrade extends DetailPendingEvent {
  final String tradeId;

  CloseTrade({
    required this.tradeId
  });
}
