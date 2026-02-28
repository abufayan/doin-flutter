import 'package:hive/hive.dart';
import 'tickmodel.dart';

class LocalPriceCacheService {
  static const String _boxName = 'price_cache';
  static const String _key = 'latest_prices';

  Box get _box => Hive.box(_boxName);

  Future<void> savePrices(Map<String, PriceTick> ticks) async {
    final mapToStore = ticks.map(
          (key, value) => MapEntry(key, {
        'symbol': value.symbol,
        'b': value.bid,
        'a': value.ask,
        'p': value.last,
        't': value.timestamp,
      }),
    );

    await _box.put(_key, mapToStore);
  }

  Map<String, PriceTick> loadPrices() {
    final raw = _box.get(_key);

    if (raw == null) return {};

    return Map<String, PriceTick>.from(
      (raw as Map).map(
            (key, value) => MapEntry(
          key,
          PriceTick.fromMap(Map<String, dynamic>.from(value)),
        ),
      ),
    );
  }
}