class SymbolMapper {
  static const Map<String, String> _map = {
    // 🔸 Metals
    'XAUUSD': 'ONA:XAUUSD',
    'XAGUSD': 'GMC:XAGUSD',
    'XPDUSD': 'GMC:XPDUSD',
    'XCUUSD': 'ONA:XCUUSD',

    // 🔸 Forex
    'EURUSD': 'ONA:EURUSD',
    'GBPUSD': 'ONA:GBPUSD',
    'USDJPY': 'ONA:USDJPY',
    'AUDUSD': 'ONA:AUDUSD',
    'USDCAD': 'ONA:USDCAD',
    'USDCHF': 'ONA:USDCHF',
    'NZDUSD': 'ONA:NZDUSD',

    // 🔸 Added Forex
    'AUDJPY': 'ONA:AUDJPY',
    'AUDCAD': 'ONA:AUDCAD',
    'AUDNZD': 'ONA:AUDNZD',
    'AUDCHF': 'ONA:AUDCHF',

    'CADCHF': 'ONA:CADCHF',
    'CADJPY': 'ONA:CADJPY',
    'CHFJPY': 'ONA:CHFJPY',

    'EURJPY': 'ONA:EURJPY',
    'EURGBP': 'ONA:EURGBP',
    'EURAUD': 'ONA:EURAUD',
    'EURNZD': 'ONA:EURNZD',
    'EURCAD': 'ONA:EURCAD',
    'EURCHF': 'ONA:EURCHF',

    'GBPJPY': 'ONA:GBPJPY',
    'GBPAUD': 'ONA:GBPAUD',
    'GBPCAD': 'ONA:GBPCAD',
    'GBPCHF': 'ONA:GBPCHF',
    'GBPNZD': 'ONA:GBPNZD',

    'NZDCAD': 'ONA:NZDCAD',
    'NZDCHF': 'ONA:NZDCHF',
    'NZDJPY': 'ONA:NZDJPY',

    'USDNZD': 'ONA:USDNZD',
    'USDGBP': 'ONA:USDGBP',
    'USDAUD': 'ONA:USDAUD',

    // 🔸 Crypto
    'ETHUSD': 'CRYPTO:ETHUSD',
    'BTCUSD': 'CRYPTO:BTCUSD',
    'BTCUSDT': 'CRYPTO:BTCUSDT',

    // 🔸 Indices (unchanged)
    'NAS100': 'OANDA:NAS100USD',
    'US30': 'OANDA:US30USD',
    'SPX500': 'OANDA:SPX500USD',
    'GER40': 'OANDA:DE40EUR',
    'UK100': 'OANDA:UK100GBP',
  };

  static String map(String rawSymbol) {
    return _map[rawSymbol.toUpperCase()] ?? 'ONA:$rawSymbol';
  }
}
