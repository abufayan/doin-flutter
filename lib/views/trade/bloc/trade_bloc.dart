import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/Market/marketService.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/core/services/wallet_service.dart';
import 'package:doin_fx/core/services/Market/tickmodel.dart';
import 'package:doin_fx/datamodel/order_model.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/orders/datamodel/trade_order.dart';

import 'trade_event.dart';
import 'trade_state.dart';

class TradeBloc extends Bloc<TradeEvent, TradeState> {
  final MarketPriceService _priceService = getIt<MarketPriceService>();

  late final StreamSubscription _priceSub;

  static const double leverage = 100;

  double _lot = 0.01;
  String _symbol = '';

  List<TradeOrder> _orders = [];

  TradeBloc() : super(TradeInitial()) {
    /// Subscribe to global price stream
    _priceSub = _priceService.stream.listen((tick) {
      final cleanSymbol = _symbol.replaceAll('/', '').trim();

      if (tick.symbol == cleanSymbol) {
        add(TradePriceUpdated(tick));
      } else {
        if (_orders.any((o) => o.symbol.replaceAll('/', '') == tick.symbol)) {
          add(TradeRecalculate());
        }
      }
    });

    on<TradeStarted>(_onStarted);
    on<TradeLotChanged>(_onLotChanged);
    on<TradePriceUpdated>(_onPriceUpdated);
    on<TradeRecalculate>(_onRecalculate);
    on<TradeBuyPressed>(_onBuy);
    on<TradeSellPressed>(_onSell);
  }

  /* ---------------- START ---------------- */

  Future<void> _onStarted(TradeStarted event, Emitter<TradeState> emit) async {
    _symbol = event.symbol;
    _lot = 0.01;

    _orders = await _loadOpenTrades();

    emit(_buildQuoteState());
  }

  /* ---------------- LOAD OPEN TRADES ---------------- */

  Future<List<TradeOrder>> _loadOpenTrades() async {
    try {
      final accountType = getIt<MyAccountService>().accountType ?? AccountType.live;

      final url = accountType == AccountType.demo ? baseUrl + demoGetTrades : baseUrl + getTrades;

      final params = {'user_id': getIt<MyAccountService>().user?.userId, 'status': 'active'};

      final response = await dio.get(url, queryParameters: params);

      final parsed = OpenOrdersResponse.fromJson(response.data);

      if (parsed.status == 'success') {
        return parsed.data;
      }
    } catch (_) {}

    return [];
  }

  /* ---------------- LOT CHANGE ---------------- */

  void _onLotChanged(TradeLotChanged event, Emitter<TradeState> emit) {
    _lot = event.lot ?? 0;
    emit(_buildQuoteState());
  }

  /* ---------------- PRICE UPDATE ---------------- */

  void _onPriceUpdated(TradePriceUpdated event, Emitter<TradeState> emit) {
    emit(_buildQuoteState());
  }

  void _onRecalculate(TradeRecalculate event, Emitter<TradeState> emit) {
    emit(_buildQuoteState());
  }

  /* ---------------- PNL CALC ---------------- */

  double _calculatePnl({required TradeOrder order, required PriceTick tick}) { 
    final entry = double.parse(order.entryPrice);
    final lot = double.parse(order.lotSize);

    final cleanSymbol = order.symbol.replaceAll('/', '').trim();

    final isGold = cleanSymbol == 'XAUUSD';
    final isSilver = cleanSymbol == 'XAGUSD';

    double contractSize = isGold ? 100 : 100000;

      if(isSilver) {
      contractSize = 5000;
    }

    // 🔥 Correct cmp
    final currentPrice = tick.last;

    final diff = order.type == 'BUY' ? currentPrice - entry : entry - currentPrice;

    double pnlQuote = diff * lot * contractSize;

    String? quote;
    if (cleanSymbol.length >= 6) {
      quote = cleanSymbol.substring(cleanSymbol.length - 3);
    }

    if (quote != null && quote != "USD") { 
      final direct = _priceService.latestTicks["USD$quote"];
      final inverse = _priceService.latestTicks["${quote}USD"];

      if (direct != null && direct.last != 0) {
        pnlQuote = pnlQuote / direct.last;
      } else if (inverse != null && inverse.last != 0) {
        pnlQuote = pnlQuote * inverse.last;
      }
    }

    return pnlQuote;
  }

  /* ---------------- STATE BUILDER ---------------- */

  TradeQuoteState _buildQuoteState() { 
    final account = getIt<MyAccountService>();

    final balance = account.wallet ?? 0.0;
    final usedMargin = account.usedMargin ?? 0.0;

    final cleanSymbol = _symbol.replaceAll('/', '').trim();

    final tick = _priceService.latestTicks[cleanSymbol];

    if (tick == null) {
      return TradeQuoteState(symbol: _symbol, cmp: 0, lot: _lot, requiredMargin: 0, freeMargin: balance);
    }

    final isGold = cleanSymbol == 'XAUUSD';
    final isSilver = cleanSymbol == 'XAGUSD';

    double contractSize = isGold ? 100 : 100000;
    if(isSilver) {
      contractSize = 5000;
    }

    final price = tick.last; // use ask for preview

    double marginQuote = (_lot * contractSize * price) / leverage; 

    String? quote;
    if (cleanSymbol.length >= 6) {
      quote = cleanSymbol.substring(cleanSymbol.length - 3);
    }

    if (quote != null && quote != "USD") {
      final direct = _priceService.latestTicks["USD$quote"];
      final inverse = _priceService.latestTicks["${quote}USD"];

      if (direct != null && direct.last != 0) {
        marginQuote = marginQuote / direct.last;
      } else if (inverse != null && inverse.last != 0) {
        marginQuote = marginQuote * inverse.last;
      }
    }

    final requiredMargin = double.parse(marginQuote.toStringAsFixed(3));

    double totalPnl = 0.0;

    for (final order in _orders) {
      final orderSymbol = order.symbol.replaceAll('/', '');

      final orderTick = _priceService.latestTicks[orderSymbol];

      if (orderTick == null) continue;

      totalPnl += _calculatePnl(order: order, tick: orderTick);
    }

    final equity = balance + totalPnl;
    final freeMargin = equity - usedMargin;

    return TradeQuoteState(
      symbol: _symbol,
      cmp: tick.last,
      lot: _lot,
      requiredMargin: requiredMargin,
      freeMargin: freeMargin,
    );
  }

  Future<void> _onBuy(TradeBuyPressed event, Emitter<TradeState> emit) async {
    if (state is TradeQuoteState) {
      emit((state as TradeQuoteState).copyWith(isSubmitting: true));
    }

    try {
      final accountType = getIt<MyAccountService>().accountType ?? AccountType.live;

      final url = accountType == AccountType.demo ? baseUrl + demoPlaceOrder : baseUrl + placeOrder;

      final cleanSymbol = _symbol.replaceAll('/', '').trim();

      final tick = _priceService.latestTicks[cleanSymbol];

      if (tick == null) {
        emit(TradeFailure("No price available"));
        emit(_buildQuoteState());
        return;
      }

      /// 🔥 BUY executes at ASK
      final executionPrice = tick.last;

      final data = Map<String, dynamic>.from(event.data)
        ..addAll({'type': 'BUY', 'price': executionPrice, 'user_id': getIt<MyAccountService>().user!.userId});

      final res = await dio.post(url, data: data);

      _lot = 0.01;

      await WalletService.updateAccountService();

      emit(TradeBuySuccess(BuyOrderModel.fromJson(res.data)));

      emit(_buildQuoteState());
    } on DioException catch (e) {
      emit(TradeFailure(e.response?.data['message'] ?? 'Buy failed'));
      emit(_buildQuoteState());
    }
  }

  Future<void> _onSell(TradeSellPressed event, Emitter<TradeState> emit) async {
    if (state is TradeQuoteState) {
      emit((state as TradeQuoteState).copyWith(isSubmitting: true));
    }

    try {
      final accountType = getIt<MyAccountService>().accountType ?? AccountType.live;

      final url = accountType == AccountType.demo ? baseUrl + demoPlaceOrder : baseUrl + placeOrder;

      final cleanSymbol = _symbol.replaceAll('/', '').trim();

      final tick = _priceService.latestTicks[cleanSymbol];

      if (tick == null) {
        emit(TradeFailure("No price available"));
        emit(_buildQuoteState());
        return;
      }

      /// 🔥 SELL executes at BID
      final executionPrice = tick.last;

      final data = Map<String, dynamic>.from(event.data)
        ..addAll({'type': 'SELL', 'price': executionPrice, 'user_id': getIt<MyAccountService>().user!.userId});

      final res = await dio.post(url, data: data);

      _lot = 0.01;

      await WalletService.updateAccountService();

      emit(TradeSellSuccess(SellOrderModel.fromJson(res.data)));

      emit(_buildQuoteState());
    } on DioException catch (e) {
      emit(TradeFailure(e.response?.data['message'] ?? 'Sell failed'));
      emit(_buildQuoteState());
    }
  }

  /* ---------------- CLEANUP ---------------- */

  @override
  Future<void> close() {
    _priceSub.cancel();
    return super.close();
  }
}
