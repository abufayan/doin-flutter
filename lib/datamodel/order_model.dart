// ignore_for_file: non_constant_identifier_names

import 'package:meta/meta.dart';

@immutable
class BuyOrderModel {
  final String? status;
  final String? message;
  final BuyPlaceOrderData? data;

  const BuyOrderModel({
    this.status,
    this.message,
    this.data,
  });

  factory BuyOrderModel.fromJson(Map<String, dynamic> json) {
    return BuyOrderModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? BuyPlaceOrderData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}


@immutable
class BuyPlaceOrderData {
  final int? trade_id;
  final int? user_id;
  final String? symbol;
  final String? type;
  final String? order_type;
  final String? lot_size;
  final double? entry_price;
  final String? entry_time;
  final double? used_margin;
  final double? take_profit;
  final double? stop_loss;
  final String? order_status;
  final double? current_price;

  const BuyPlaceOrderData({
    this.trade_id,
    this.user_id,
    this.symbol,
    this.type,
    this.order_type,
    this.lot_size,
    this.entry_price,
    this.entry_time,
    this.used_margin,
    this.take_profit,
    this.stop_loss,
    this.order_status,
    this.current_price,
  });

  factory BuyPlaceOrderData.fromJson(Map<String, dynamic> json) {
    return BuyPlaceOrderData(
      trade_id: json['trade_id'] as int?,
      user_id: json['user_id'] as int?,
      symbol: json['symbol'] as String?,
      type: json['type'] as String?,
      order_type: json['order_type'] as String?,
      lot_size: json['lot_size']?.toString(),
      entry_price: (json['entry_price'] as num?)?.toDouble(),
      entry_time: json['entry_time'] as String?,
      used_margin: (json['used_margin'] as num?)?.toDouble(),
      take_profit: (json['take_profit'] as num?)?.toDouble(),
      stop_loss: (json['stop_loss'] as num?)?.toDouble(),
      order_status: json['order_status'] as String?,
      current_price: (json['current_price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'trade_id': trade_id,
    'user_id': user_id,
    'symbol': symbol,
    'type': type,
    'order_type': order_type,
    'lot_size': lot_size,
    'entry_price': entry_price,
    'entry_time': entry_time,
    'used_margin': used_margin,
    'take_profit': take_profit,
    'stop_loss': stop_loss,
    'order_status': order_status,
    'current_price': current_price,
  };
}


//////////////////////// SELL ////////////////////////////////////////////////////////

@immutable
class SellOrderModel {
  final String? status;
  final String? message;
  final SellOrderPlacedData? data;

  const SellOrderModel({
    this.status,
    this.message,
    this.data,
  });

  factory SellOrderModel.fromJson(Map<String, dynamic> json) {
    return SellOrderModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? SellOrderPlacedData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

@immutable
class SellOrderPlacedData {
  final int? trade_id;
  final int? user_id;
  final String? symbol;
  final String? type;
  final String? order_type;
  final String? lot_size;
  final int? leverage;
  final double? trigger_price;
  final String? order_status;
  final double? current_market_price;

  const SellOrderPlacedData({
    this.trade_id,
    this.user_id,
    this.symbol,
    this.type,
    this.order_type,
    this.lot_size,
    this.leverage,
    this.trigger_price,
    this.order_status,
    this.current_market_price,
  });

  factory SellOrderPlacedData.fromJson(Map<String, dynamic> json) {
    return SellOrderPlacedData(
      trade_id: json['trade_id'] as int?,
      user_id: json['user_id'] as int?,
      symbol: json['symbol'] as String?,
      type: json['type'] as String?,
      order_type: json['order_type'] as String?,
      lot_size: json['lot_size']?.toString(),
      leverage: json['leverage'] as int?,
      trigger_price: (json['trigger_price'] as num?)?.toDouble(),
      order_status: json['order_status'] as String?,
      current_market_price:
          (json['current_market_price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'trade_id': trade_id,
    'user_id': user_id,
    'symbol': symbol,
    'type': type,
    'order_type': order_type,
    'lot_size': lot_size,
    'leverage': leverage,
    'trigger_price': trigger_price,
    'order_status': order_status,
    'current_market_price': current_market_price,
  };
}

