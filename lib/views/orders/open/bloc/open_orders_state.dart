part of 'open_orders_bloc.dart';

@immutable
sealed class OpenOrdersState {}

final class OpenOrdersInitial extends OpenOrdersState {}

final class OpenOrdersLoading extends OpenOrdersState {}

final class OpenOrdersLoaded extends OpenOrdersState {
  final List<TradeOrder> orders;

  final double balance;
  final double usedMargin;

  final double totalPnl;
  final double equity;
  final double freeMargin;
  final double marginLevel;
  final double accountLevel;

  OpenOrdersLoaded({
    required this.orders,
    required this.balance,
    required this.usedMargin,
    required this.totalPnl,
    required this.equity,
    required this.freeMargin,
    required this.marginLevel,
    required this.accountLevel,
  });

  OpenOrdersLoaded copyWith({
    List<TradeOrder>? orders,
    double? totalPnl,
    double? balance,
    double? equity,
    double? usedMargin,
    double? freeMargin,
    double? marginLevel,
    double? accountLevel,
  }) {
    return OpenOrdersLoaded(
      orders: orders ?? this.orders,
      totalPnl: totalPnl ?? this.totalPnl,
      balance: balance ?? this.balance,
      equity: equity ?? this.equity,
      usedMargin: usedMargin ?? this.usedMargin,
      freeMargin: freeMargin ?? this.freeMargin,
      marginLevel: marginLevel ?? this.marginLevel,
      accountLevel: accountLevel ?? this.accountLevel,
    );
  }
}

abstract class OpenOrdersActionState extends OpenOrdersState {}

class ActionSuccess extends OpenOrdersActionState {
  final String message;
  ActionSuccess(this.message);
}

class UpdateTradeSuccess extends OpenOrdersActionState {
  final String message;
  UpdateTradeSuccess({required this.message});
}

class UpdateTradeError extends OpenOrdersActionState {
  final String message;
  UpdateTradeError({required this.message});
}

class CloseTradeError extends OpenOrdersActionState {
  final String message;
  CloseTradeError({required this.message});
}

class CloseTradeSuccess extends OpenOrdersActionState {
  final String message;
  CloseTradeSuccess({required this.message});
}

class TradeClosed extends OpenOrdersActionState {
  final String message;
  TradeClosed({required this.message});
}

final class OpenOrdersError extends OpenOrdersActionState {
  final String message;

  OpenOrdersError({required this.message});
}

/// State emitted when edit values are reset to original
// class EditValuesReset extends OpenOrdersActionState { 
//   final double? originalTakeProfit;
//   final double? originalStopLoss;
  
//   EditValuesReset({
//     this.originalTakeProfit,
//     this.originalStopLoss,
//   });
// }
