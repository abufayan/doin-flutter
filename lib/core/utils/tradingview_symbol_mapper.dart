class TradingViewSymbolMapper {
  static const Map<String, String> _map = {
    // 🔸 Metals
    'XAUUSD': 'OANDA:XAUUSD',
    'XAGUSD': 'OANDA:XAGUSD',

    // 🔸 Forex
    'EURUSD': 'OANDA:EURUSD',
    'GBPUSD': 'OANDA:GBPUSD',
    'USDJPY': 'OANDA:USDJPY',
    'AUDUSD': 'OANDA:AUDUSD',
    'USDCAD': 'OANDA:USDCAD',
    'USDCHF': 'OANDA:USDCHF',
    'NZDUSD': 'OANDA:NZDUSD',

    // 🔸 Crypto
    'BTCUSDT': 'BINANCE:BTCUSDT',
    'ETHUSDT': 'BINANCE:ETHUSDT',
    'BTCUSD': 'COINBASE:BTCUSD',

    // 🔸 Indices (CFD style)
    'NAS100': 'OANDA:NAS100USD',
    'US30': 'OANDA:US30USD',
    'SPX500': 'OANDA:SPX500USD',
    'GER40': 'OANDA:DE40EUR',
    'UK100': 'OANDA:UK100GBP',
  };

  static String map(String rawSymbol) {
    return _map[rawSymbol.toUpperCase()] ?? 'OANDA:$rawSymbol';
  }
}
