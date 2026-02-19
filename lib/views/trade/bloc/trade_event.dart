import 'package:flutter/material.dart';
import 'package:doin_fx/core/services/Market/tickmodel.dart';

sealed class TradeEvent {}

class TradeStarted extends TradeEvent {
  final String symbol;
  TradeStarted({required this.symbol});
}

class TradeLotChanged extends TradeEvent {
  final double? lot;
  TradeLotChanged({required this.lot});
}

class TradeBuyPressed extends TradeEvent {
  final Map<String, dynamic> data;
  final BuildContext context;
  TradeBuyPressed({required this.data, required this.context});
}

class TradeSellPressed extends TradeEvent {
  final Map<String, dynamic> data;
  final BuildContext context;
  TradeSellPressed({required this.data, required this.context});
}

class TradePriceUpdated extends TradeEvent {
  final PriceTick tick;
  TradePriceUpdated(this.tick);
}

/// 🔥 NEW EVENT
class TradeRecalculate extends TradeEvent {}
