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
  String? _persistentError;
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
    _persistentError = null;

    final cleanSymbol = _symbol.replaceAll('/', '').trim();

    if (cleanSymbol == 'ETHUSD') {
      _lot = 0.1;
    } else {
      _lot = 0.01;
    }

    // 🔥 Emit immediately so popup gets correct lot
    emit(_buildQuoteState());

    // Then load orders async
    _orders = await _loadOpenTrades();

    // Emit again after orders load
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

  //Origianal version if new version creates issues then use this
  // void _onLotChanged(TradeLotChanged event, Emitter<TradeState> emit) {
  //   if (event.lot == null) return;

  //   final isEth = _symbol.contains('ETH');
  //   final minLot = isEth ? 0.10 : 0.01;

  //   final sanitized = event.lot!.isFinite ? event.lot! : minLot;

  //   _lot = sanitized.clamp(minLot, double.infinity);

  //   emit(_buildQuoteState());
  // }

  void _onLotChanged(TradeLotChanged event, Emitter<TradeState> emit) {
    final isEth = _symbol.contains('ETH');
    final minLot = isEth ? 0.10 : 0.01;

    if (event.lot == null) {
      _lot = 0.0; // allow empty/invalid
    } else {
      _lot = event.lot!; // allow raw value (even 0)
    }

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
    final isCrypto = (cleanSymbol == 'BTCUSD' || cleanSymbol == 'ETHUSD');
    // final isCrypto = cleanSymbol.length > 6;

    double contractSize = isGold ? 100 : 100000;

    if (isSilver) {
      contractSize = 5000;
    }
    if (isCrypto) {
      contractSize = 1;
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
    final isCrypto = (cleanSymbol == 'BTCUSD' || cleanSymbol == 'ETHUSD');

    double contractSize = isGold ? 100 : 100000;
    if (isSilver) {
      contractSize = 5000;
    }
    if (isCrypto) {
      contractSize = 1;
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
      errorMessage: _persistentError, // 🔥 use persistent error
    );
  }

  Future<void> _onBuy(TradeBuyPressed event, Emitter<TradeState> emit) async {
    if (state is TradeQuoteState) {
      if (state is TradeQuoteState) {
        _persistentError = null;

        emit((state as TradeQuoteState).copyWith(isSubmitting: true, errorMessage: null));
      }
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

      final symbol = _symbol.replaceAll('/', '').trim();
      _lot = symbol == 'ETHUSD' ? 0.10 : 0.01;

      await WalletService.updateAccountService();

      emit(TradeBuySuccess(BuyOrderModel.fromJson(res.data)));

      emit(_buildQuoteState());
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Buy failed';
      _persistentError = msg;
      emit(_buildQuoteState());
    }
  }

  Future<void> _onSell(TradeSellPressed event, Emitter<TradeState> emit) async {
    if (state is TradeQuoteState) {
      _persistentError = null;

      emit((state as TradeQuoteState).copyWith(isSubmitting: true, errorMessage: null));
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

      final symbol = _symbol.replaceAll('/', '').trim();
      _lot = symbol == 'ETHUSD' ? 0.10 : 0.01;

      await WalletService.updateAccountService();

      emit(TradeSellSuccess(SellOrderModel.fromJson(res.data)));

      emit(_buildQuoteState());
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Sell failed';
      _persistentError = msg;
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
