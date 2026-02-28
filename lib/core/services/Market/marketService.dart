import 'dart:async';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/setup.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:doin_fx/core/locator.dart';
import 'local_price_cache_service.dart';
import 'tickmodel.dart';

class MarketPriceService {

  late final LocalPriceCacheService _cacheService;
  Timer? _cacheTimer;

  MarketPriceService() {
    _cacheService = getIt<LocalPriceCacheService>();
  }
  IO.Socket? _socket;

  final _controller = StreamController<PriceTick>.broadcast();

  Stream<PriceTick> get stream => _controller.stream;

  final Map<String, PriceTick> _latestTicks = {};

  Map<String, PriceTick> get latestTicks => _latestTicks;

  Future<void> connect() async {
    print("🟢 MarketPriceService.connect() called");
    if (_socket != null) return;

    // 🔥 Restore cached prices immediately
    final cached = _cacheService.loadPrices();

    print("🔥 Restored ${cached.length} prices from cache"); // 👈 ADD HERE
    _latestTicks.addAll(cached);

    for (final tick in cached.values) {
      _controller.add(tick);
    }

    String localUrl = appType == AppType.Local ? 'ws://192.168.1.42:5000' : 'wss://api.dointrade.com';



    _socket = IO.io(
      '${localUrl}',
      IO.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    );

    _socket!.onConnect((_) {
      _socket!.send(['40']);
    });

    _socket!.onAny((event, data) {
      if (event == 'forex_update' && data is Map) {
        try {
          final tick = PriceTick.fromMap(data as Map<String, dynamic>);

          _latestTicks[tick.symbol] = tick;

          _controller.add(tick);
        } catch (_) {
          // Ignore malformed tick
        }
      }
    });

    _socket!.connect();
    _startCacheSync();
  }

  void _startCacheSync() {
    print("💾 Saving ${_latestTicks.length} prices");
    _cacheTimer?.cancel();

    _cacheTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_latestTicks.isNotEmpty) {
        _cacheService.savePrices(_latestTicks);
      }
    });
  }

  void dispose() {
    _cacheTimer?.cancel();
    _socket?.disconnect();
    _socket?.dispose();
    _controller.close();
  }
}
