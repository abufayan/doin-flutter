class PriceTick {
  final String symbol;
  final double bid;
  final double ask;
  final double last;
  final int timestamp;

  PriceTick({required this.symbol, required this.bid, required this.ask, required this.last, required this.timestamp});

  factory PriceTick.fromMap(Map<String, dynamic> data) {
    return PriceTick(
      symbol: data['symbol'].toString().replaceAll('/', '').trim(),
      last: (data['p'] as num).toDouble(),
      bid: (data['b'] as num).toDouble(),
      ask: (data['a'] as num).toDouble(),
      timestamp: (data['t'] as num).toInt(),
    );
  }
}
