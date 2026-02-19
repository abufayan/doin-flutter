import 'package:doin_fx/datamodel/order_model.dart';

sealed class TradeState {}

class TradeInitial extends TradeState {}

class TradeLoading extends TradeState {}

/// 🔥 LIVE QUOTE STATE (this drives popup UI)
class TradeQuoteState extends TradeState {
  final String symbol;
  final double cmp;
  final double lot;
  final double requiredMargin;
  final double freeMargin;
  final bool isSubmitting;

  TradeQuoteState({
    required this.symbol,
    required this.cmp,
    required this.lot,
    required this.requiredMargin,
    required this.freeMargin,
    this.isSubmitting = false,
  });

  TradeQuoteState copyWith({
    double? cmp,
    double? lot,
    double? requiredMargin,
    double? freeMargin,
    bool? isSubmitting,
  }) {
    return TradeQuoteState(
      symbol: symbol,
      cmp: cmp ?? this.cmp,
      lot: lot ?? this.lot,
      requiredMargin: requiredMargin ?? this.requiredMargin,
      freeMargin: freeMargin ?? this.freeMargin,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// ACTION STATES
sealed class TradeActionState extends TradeState {}

class TradeBuySuccess extends TradeActionState {
  final BuyOrderModel order;
  TradeBuySuccess(this.order);
}

class TradeSellSuccess extends TradeActionState {
  final SellOrderModel order;
  TradeSellSuccess(this.order);
}

class TradeFailure extends TradeActionState {
  final String message;
  TradeFailure(this.message);
}
