import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/orders/datamodel/open_orders.dart';
import 'package:meta/meta.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

part 'open_orders_event.dart';
part 'open_orders_state.dart';

class OpenOrdersBloc extends Bloc<OpenOrdersEvent, OpenOrdersState> {
  IO.Socket? _socket;

  static const double stopOutLevel = 50.0;
  bool _isStopOutInProgress = false;

  OpenOrdersBloc() : super(OpenOrdersInitial()) {
    on<LoadOpenOrders>(_loadOpenOrders);
    on<ConnectSocket>(_connectSocket);
    on<PriceUpdated>(_priceUpdated);
  }

  /* ---------------- LOAD ORDERS ---------------- */

  FutureOr<void> _loadOpenOrders(
      LoadOpenOrders event,
      Emitter<OpenOrdersState> emit,
      ) async {
    emit(OpenOrdersLoading());

    try {
      final params = {
        'user_id': getIt<MyAccountService>().user?.userId,
        'status': 'active',
      };

      final response =
      await dio.get(baseUrl + getOpenTrades, queryParameters: params);

      final parsed = OpenOrdersResponse.fromJson(response.data);

      if (parsed.status != 'success') {
        emit(OpenOrdersError(message: parsed.message));
        return;
      }

      emit(_buildLoadedState(orders: parsed.data));
    } catch (e) {
      emit( OpenOrdersError(message: 'Failed to load open orders'));
    }
  }

  /* ---------------- SOCKET ---------------- */

  void _connectSocket(
      ConnectSocket event,
      Emitter<OpenOrdersState> emit,
      ) {
    if (_socket != null) {
      // socket already connected → do nothing
      return;
    }

    _socket = IO.io(
      'wss://api.dointrade.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      _socket!.send(['40']);
    });

    _socket!.onAny((event, data) {
      if (isClosed) return;

      if (event == 'forex_update' && data is Map) {
        final symbol = data['symbol'] as String?;
        final price = data['p'];
        final low = data['a'];
        final high = data['b'];

        if (symbol != null && price != null) {
          add(
            PriceUpdated(
              symbol: symbol,
              cmp: (price as num).toDouble(),
              low: (low as num).toDouble(),
              high: (high as num).toDouble(),
            ),
          );
        }
      }
    });

    _socket!.connect();
  }

  /* ---------------- PRICE UPDATE ---------------- */

  void _priceUpdated(
      PriceUpdated event,
      Emitter<OpenOrdersState> emit,
      ) {
    if (state is! OpenOrdersLoaded) return;

    final current = state as OpenOrdersLoaded;

    String norm(String s) => s.replaceAll('/', '');

    final updatedOrders = current.orders.map((order) {
      if (norm(order.symbol) == norm(event.symbol)) {
        final pnl = _calculatePnl(
          order: order,
          currentPrice: event.cmp,
        );

        return order.copyWith(
          cmp: event.cmp,
          low: event.low,
          high: event.high,
          pnl: pnl,
        );
      }
      return order;
    }).toList();

    final newState = _buildLoadedState(orders: updatedOrders);
    emit(newState);

    _handleStopOut(newState, emit);
  }

  /* ---------------- STATE BUILDER ---------------- */

  OpenOrdersLoaded _buildLoadedState({
    required List<OpenOrder> orders,
  }) {
    final account = getIt<MyAccountService>();

    final balance = account.wallet ?? 0.0;

    final usedMargin = orders.fold<double>(
      0.0,
          (sum, o) => sum + (double.tryParse(o.usedMargin) ?? 0.0),
    );

    final totalPnl =
    orders.fold<double>(0.0, (sum, o) => sum + o.pnl);

    final equity = balance + totalPnl;
    final freeMargin = equity - usedMargin;

    final marginLevel = usedMargin > 0
        ? ((equity / usedMargin) * 100).toDouble()
        : 0.0;

    return OpenOrdersLoaded(
      orders: orders,
      balance: balance,
      usedMargin: usedMargin,
      totalPnl: totalPnl,
      equity: equity,
      freeMargin: freeMargin,
      marginLevel: marginLevel,
    );
  }

  /* ---------------- STOP OUT ---------------- */

  void _handleStopOut(
      OpenOrdersLoaded state,
      Emitter<OpenOrdersState> emit,
      ) {
    if (_isStopOutInProgress) return;
    if (state.marginLevel > stopOutLevel) return;

    _isStopOutInProgress = true;

    final sorted = [...state.orders]
      ..sort((a, b) => a.pnl.compareTo(b.pnl));

    final remaining = [...state.orders];

    for (final order in sorted) {
      if (state.marginLevel > stopOutLevel) break;

      remaining.remove(order);

      final newState = _buildLoadedState(orders: remaining);
      emit(newState);
    }

    _isStopOutInProgress = false;
  }

  /* ---------------- CLEANUP ---------------- */

  @override
  Future<void> close() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    return super.close();
  }
}

/* ---------------- PNL CALC ---------------- */

double _calculatePnl({
  required OpenOrder order,
  required double currentPrice,
}) {
  final entry = double.parse(order.entryPrice);
  final lot = double.parse(order.lotSize);

  final isGold = order.symbol.replaceAll('/', '') == 'XAUUSD';
  final contractSize = isGold ? 100 : 100000;

  final diff = order.type == 'BUY'
      ? currentPrice - entry
      : entry - currentPrice;

  return diff * lot * contractSize;
}
