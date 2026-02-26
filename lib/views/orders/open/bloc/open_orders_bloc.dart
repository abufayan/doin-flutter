import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/Market/marketService.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/core/services/wallet_service.dart';
import 'package:doin_fx/core/services/Market/tickmodel.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/orders/datamodel/trade_order.dart';
import 'package:meta/meta.dart';

part 'open_orders_event.dart';
part 'open_orders_state.dart';

class OpenOrdersBloc extends Bloc<OpenOrdersEvent, OpenOrdersState> {
  final MarketPriceService _priceService = getIt<MarketPriceService>();

  late final StreamSubscription _priceSub;

  /// 🔥 Store full tick model now
  final Map<String, PriceTick> _latestTicks = {};

  OpenOrdersBloc() : super(OpenOrdersInitial()) {
    /// 🔥 Subscribe to global price stream
    _priceSub = _priceService.stream.listen((tick) {
      add(PriceUpdated(tick));
    });

    on<LoadOpenOrders>(_loadOpenOrders);
    on<PriceUpdated>(_priceUpdated);
    on<CloseAllTrades>(_closeAllTrades);
    on<CloseAllProfitTrades>(_closeAllProfitTrades);
    on<CloseAllLossTrades>(_closeAllLossTrades);
    on<UpdateTrade>(updateTrade);
    on<CloseTrade>(closeTrade);
  }

  /* ---------------- LOAD ORDERS ---------------- */

  FutureOr<void> _loadOpenOrders(LoadOpenOrders event, Emitter<OpenOrdersState> emit) async {
    event.showLoading ? emit(OpenOrdersLoading()) : null;

    await WalletService.updateAccountService();

    try {
      final accountType = getIt<MyAccountService>().accountType ?? AccountType.live;

      final url = accountType == AccountType.demo ? baseUrl + demoGetTrades : baseUrl + getTrades;

      final params = {'user_id': getIt<MyAccountService>().user?.userId, 'status': 'active'};

      final response = await dio.get(url, queryParameters: params);

      final parsed = OpenOrdersResponse.fromJson(response.data);

      if (parsed.status != 'success') {
        emit(OpenOrdersError(message: parsed.message));
        return;
      }

      emit(_buildLoadedState(orders: parsed.data));
    } on DioException catch (e) {
      emit(OpenOrdersError(message: e.response?.data['message'] ?? 'Failed to load open orders'));
    } catch (e) {
      emit(OpenOrdersError(message: 'Failed to load open orders: $e'));
    }
  }

  /* ---------------- PRICE UPDATE ---------------- */

  void _priceUpdated(PriceUpdated event, Emitter<OpenOrdersState> emit) {
    if (state is! OpenOrdersLoaded) return;

    final current = state as OpenOrdersLoaded;
    if (current.orders.isEmpty) return;

    final tick = event.tick;
    final normalizedSymbol = tick.symbol.replaceAll('/', '');

    _latestTicks[normalizedSymbol] = tick;

    final updatedOrders = current.orders.map((order) {
      final orderSymbol = order.symbol.replaceAll('/', '');

      if (orderSymbol == normalizedSymbol) {
        final pnl = _calculatePnl(order: order, tick: tick);

        return order.copyWith(cmp: tick.last, low: tick.bid, high: tick.ask, pnl: pnl);
      }

      return order;
    }).toList();

    emit(_buildLoadedState(orders: updatedOrders));
  }

  /* ---------------- STATE BUILDER ---------------- */

  OpenOrdersLoaded _buildLoadedState({required List<TradeOrder> orders}) {
    final account = getIt<MyAccountService>();
    final balance = account.wallet ?? 0.0;

    double totalUsedMargin = 0.0;

    for (final order in orders) {
      totalUsedMargin += double.tryParse(order.usedMargin) ?? 0.0;
    }

    final totalPnl = orders.fold<double>(0.0, (sum, o) => sum + o.pnl);

    final equity = balance + totalPnl;
    final freeMargin = equity - totalUsedMargin;

    double marginLevel = 0.0;
    if (totalUsedMargin > 0) {
      marginLevel = (equity / totalUsedMargin) * 100;
    }

    final accountLevel = (equity / balance) * 100;

    return OpenOrdersLoaded(
      orders: orders,
      balance: balance,
      usedMargin: totalUsedMargin,
      totalPnl: totalPnl,
      equity: equity,
      freeMargin: freeMargin,
      marginLevel: marginLevel,
      accountLevel: accountLevel,
    );
  }

  /* ---------------- PNL CALC ---------------- */

  double _calculatePnl({required TradeOrder order, required PriceTick tick}) {
    final entry = double.parse(order.entryPrice);
    final lot = double.parse(order.lotSize);

    final cleanSymbol = order.symbol.replaceAll('/', '').trim();

    final isGold = cleanSymbol == 'XAUUSD';
    final isSilver = cleanSymbol == 'XAGUSD';
    final isCrypto = (cleanSymbol == 'BTCUSD' || cleanSymbol == 'ETHUSD');
    double contractSize = isGold ? 100 : 100000;

    if (isSilver) {
      contractSize = 5000;
    }

    if (isCrypto) {
      contractSize = 1;
    }

    /// 🔥 Correct broker logic
    final currentPrice = tick.last;

    final diff = order.type == 'BUY' ? currentPrice - entry : entry - currentPrice;

    double pnlQuote = diff * lot * contractSize;

    String? quote;
    if (cleanSymbol.length >= 6) {
      quote = cleanSymbol.substring(cleanSymbol.length - 3);
    }

    if (quote != null && quote != "USD") {
      final direct = _latestTicks["USD$quote"];
      final inverse = _latestTicks["${quote}USD"];

      if (direct != null && direct.last != 0) {
        pnlQuote = pnlQuote / direct.last;
      } else if (inverse != null && inverse.last != 0) {
        pnlQuote = pnlQuote * inverse.last;
      }
    }

    return pnlQuote;
  }

  /* ---------------- CLOSE ALL LOGIC ---------------- */

  Future<void> _closeAllTrades(CloseAllTrades event, Emitter<OpenOrdersState> emit) async {
    await _closeTrades(url: baseUrl + closeAllPositions, emit: emit);
  }

  Future<void> _closeAllProfitTrades(CloseAllProfitTrades event, Emitter<OpenOrdersState> emit) async {
    await _closeTrades(url: baseUrl + closeAllProfitPositions, emit: emit);
  }

  Future<void> _closeAllLossTrades(CloseAllLossTrades event, Emitter<OpenOrdersState> emit) async {
    await _closeTrades(url: baseUrl + closeAllLossPositions, emit: emit);
  }

  Future<void> _closeTrades({required String url, required Emitter<OpenOrdersState> emit}) async {
    try {
      final accountType = getIt<MyAccountService>().accountType;

      String finalUrl = url;

      if (accountType == AccountType.demo) {
        if (url.contains(closeAllPositions))
          finalUrl = baseUrl + demoCloseAllPositions;
        else if (url.contains(closeAllProfitPositions))
          finalUrl = baseUrl + demoCloseAllProfitPositions;
        else if (url.contains(closeAllLossPositions))
          finalUrl = baseUrl + demoCloseAllLossPositions;
      }

      final response = await dio.post(finalUrl, data: {'user_id': getIt<MyAccountService>().user!.userId});

      if (response.data['status'] != 'success') {
        emit(CloseTradeError(message: response.data['message'] ?? 'Action failed'));
        return;
      }

      emit(CloseTradeSuccess(message: response.data['message'] ?? 'Success'));

      await WalletService.updateAccountService();

      add(LoadOpenOrders(showLoading: false));
    } on DioException catch (e) {
      String errorMessage = 'Something went wrong';

      if (e.response != null) {
        final data = e.response?.data;

        if (data is Map<String, dynamic>) {
          errorMessage = data['message'] ?? data['error'] ?? 'Request failed';
        } else {
          errorMessage = 'Server error (${e.response?.statusCode})';
        }
      }

      emit(CloseTradeError(message: errorMessage));
    } catch (e) {
      emit(CloseTradeError(message: 'Error closing trade: $e'));
    }
  }

  /* ---------------- UPDATE TRADE ---------------- */

  FutureOr<void> updateTrade(UpdateTrade event, Emitter<OpenOrdersState> emit) async {
    try {
      final data = {'user_id': getIt<MyAccountService>().user?.userId.toString()};

      if (event.takeProfit != null) {
        data['take_profit'] = event.takeProfit!.toString();
      }

      if (event.stopLoss != null) {
        data['stop_loss'] = event.stopLoss!.toString();
      }

      final accountType = getIt<MyAccountService>().accountType;

      final baseUrlPath = accountType == AccountType.demo ? demoGetTrades : getTrades;

      final response = await dio.put('$baseUrl$baseUrlPath/${event.tradeId}/tp-sl', data: data);

      if (response.data['status'] != 'success') {
        emit(UpdateTradeError(message: response.data['message']));
        return;
      }

      emit(UpdateTradeSuccess(message: response.data['message']));
    } on DioException catch (e) {
      String errorMessage = 'Something went wrong';

      if (e.response != null) {
        final data = e.response?.data;

        if (data is Map<String, dynamic>) {
          errorMessage = data['message'] ?? data['error'] ?? 'Request failed';
        } else {
          errorMessage = 'Server error (${e.response?.statusCode})';
        }
      }

      emit(CloseTradeError(message: errorMessage));
    } catch (e) {
      emit(UpdateTradeError(message: 'Update failed: $e'));
    }
  }

  /* ---------------- CLOSE TRADE ---------------- */

  FutureOr<void> closeTrade(CloseTrade event, Emitter<OpenOrdersState> emit) async {
    try {
      final accountType = getIt<MyAccountService>().accountType;

      final baseUrlPath = accountType == AccountType.demo ? demoGetTrades : getTrades;

      final response = await dio.post(
        '$baseUrl$baseUrlPath/${event.tradeId}/close',
        data: {'user_id': getIt<MyAccountService>().user?.userId},
      );

      if (response.data['status'] != 'success') {
        emit(UpdateTradeError(message: response.data['message']));
        return;
      }

      await WalletService.updateAccountService();

      emit(TradeClosed(message: response.data['message']));
    } catch (e) {
      emit(UpdateTradeError(message: 'Close failed: $e'));
    }
  }

  /* ---------------- CLEANUP ---------------- */

  @override
  Future<void> close() {
    _priceSub.cancel();
    return super.close();
  }
}
