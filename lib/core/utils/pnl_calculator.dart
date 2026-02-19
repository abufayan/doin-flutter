class PnlCalculator {
  /// Contract size based on symbol
  static double contractSize(String symbol) {
    final normalized = symbol.replaceAll('/', '').toUpperCase();

    if (normalized == 'XAUUSD') {
      return 100; // Gold
    }

    return 100000; // Forex default
  }

  /// Calculate PnL
  static double calculate({
    required String type,        // BUY / SELL
    required double entryPrice,
    required double currentPrice,
    required double lotSize,
    required String symbol,
  }) {
    final contract = contractSize(symbol);

    final priceDiff = type == 'BUY'
        ? (currentPrice - entryPrice)
        : (entryPrice - currentPrice);

    return priceDiff * lotSize * contract;
  }
}
