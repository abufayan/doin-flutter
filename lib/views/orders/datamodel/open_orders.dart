class OpenOrdersResponse {
  final String status;
  final String message;
  final int count;
  final List<OpenOrder> data;

  OpenOrdersResponse({
    required this.status,
    required this.message,
    required this.count,
    required this.data,
  });

  factory OpenOrdersResponse.fromJson(Map<String, dynamic> json) {
    return OpenOrdersResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      count: json['count'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) => OpenOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}


class OpenOrder {
  final int tradeId;
  final int userId;
  final String symbol;
  final String type;
  final String orderType;
  final String lotSize;
  final int leverage;
  final String entryPrice;
  final DateTime entryTime;

  final String? exitPrice;
  final DateTime? exitTime;

  final String usedMargin;
  final double pnl; // instead of String

  final String? takeProfit;
  final String? stopLoss;

  final DateTime? tpUpdatedAt;
  final DateTime? slUpdatedAt;

  final String orderStatus;
  final String fee;
  final int isReferralCodeAdded;
  final String swap;
  final String commission;
  final String userBalanceAfterTrade;

  final String? closedBy;
  final DateTime createdAt;

  // 🔥 LIVE PRICE FIELDS (NEW)
  final double cmp;
  final double low;
  final double high;

  OpenOrder({
    required this.tradeId,
    required this.userId,
    required this.symbol,
    required this.type,
    required this.orderType,
    required this.lotSize,
    required this.leverage,
    required this.entryPrice,
    required this.entryTime,
    required this.exitPrice,
    required this.exitTime,
    required this.usedMargin,
    required this.pnl,
    required this.takeProfit,
    required this.stopLoss,
    required this.tpUpdatedAt,
    required this.slUpdatedAt,
    required this.orderStatus,
    required this.fee,
    required this.isReferralCodeAdded,
    required this.swap,
    required this.commission,
    required this.userBalanceAfterTrade,
    required this.closedBy,
    required this.createdAt,

    // 🔥 NEW
    required this.cmp,
    required this.low,
    required this.high,
  });

  factory OpenOrder.fromJson(Map<String, dynamic> json) {
    return OpenOrder(
      tradeId: json['trade_id'] as int,
      userId: json['user_id'] as int,
      symbol: json['symbol'] as String,
      type: json['type'] as String,
      orderType: json['order_type'] as String,
      lotSize: json['lot_size'] as String,
      leverage: json['leverage'] as int,
      entryPrice: json['entry_price'] as String,
      entryTime: DateTime.parse(json['entry_time']),

      exitPrice: json['exit_price'] as String?,
      exitTime: json['exit_time'] != null
          ? DateTime.parse(json['exit_time'])
          : null,

      usedMargin: json['used_margin'] as String,
      pnl: double.tryParse(json['pnl']?.toString() ?? '0') ?? 0.0,

      takeProfit: json['take_profit'] as String?,
      stopLoss: json['stop_loss'] as String?,

      tpUpdatedAt: json['tp_updated_at'] != null
          ? DateTime.parse(json['tp_updated_at'])
          : null,
      slUpdatedAt: json['sl_updated_at'] != null
          ? DateTime.parse(json['sl_updated_at'])
          : null,

      orderStatus: json['order_status'] as String,
      fee: json['fee'] as String,
      isReferralCodeAdded: json['is_referral_code_added'] as int,
      swap: json['swap'] as String,
      commission: json['commission'] as String,
      userBalanceAfterTrade: json['user_balance_after_trade'] as String,

      closedBy: json['closed_by'] as String?,
      createdAt: DateTime.parse(json['created_at']),

      // ✅ SAFE DEFAULTS (same pattern as favourites)
      cmp: (json['cmp'] as num?)?.toDouble() ?? 0.0,
      low: (json['l'] as num?)?.toDouble() ?? 0.0,
      high: (json['h'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// 🔁 Used for socket/live price updates
  OpenOrder copyWith({
    double? cmp,
    double? low,
    double? high,
    double? pnl,
  }) {
    return OpenOrder(
      tradeId: tradeId,
      userId: userId,
      symbol: symbol,
      type: type,
      orderType: orderType,
      lotSize: lotSize,
      leverage: leverage,
      entryPrice: entryPrice,
      entryTime: entryTime,
      exitPrice: exitPrice,
      exitTime: exitTime,
      usedMargin: usedMargin,
      pnl: pnl ?? this.pnl,
      takeProfit: takeProfit,
      stopLoss: stopLoss,
      tpUpdatedAt: tpUpdatedAt,
      slUpdatedAt: slUpdatedAt,
      orderStatus: orderStatus,
      fee: fee,
      isReferralCodeAdded: isReferralCodeAdded,
      swap: swap,
      commission: commission,
      userBalanceAfterTrade: userBalanceAfterTrade,
      closedBy: closedBy,
      createdAt: createdAt,
      cmp: cmp ?? this.cmp,
      low: low ?? this.low,
      high: high ?? this.high,
    );
  }
}
