import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'tickmodel.dart';

class MarketPriceService {
  IO.Socket? _socket;

  final _controller = StreamController<PriceTick>.broadcast();

  Stream<PriceTick> get stream => _controller.stream;

  final Map<String, PriceTick> _latestTicks = {};

  Map<String, PriceTick> get latestTicks => _latestTicks;

  Future<void> connect() async {
    if (_socket != null) return;

    _socket = IO.io(
      'wss://api.dointrade.com',
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
  }

  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _controller.close();
  }
}
