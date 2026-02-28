import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/core/services/token_storage_service.dart';
import 'package:doin_fx/core/services/wallet_service.dart';
import 'package:doin_fx/core/services/Market/marketService.dart';
import 'package:doin_fx/core/services/Market/tickmodel.dart';
import 'package:doin_fx/datamodel/pair_response.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/watch/FavouritePairs/bloc/favourites_state.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/utils/logger.dart';
import 'package:meta/meta.dart';

part 'favourites_event.dart';

class FavouritesBloc extends Bloc<FavouritesEvent, FavouritesBlocState> {
  final MarketPriceService _priceService = getIt<MarketPriceService>();

  late final StreamSubscription _priceSub;

  List<FavouriteItem> _favouritesCache = [];
  String _currentSearchQuery = '';

  FavouritesBloc() : super(FavouritesBlocInitial()) {


    /// 🔥 Subscribe to global price stream
    _priceSub = _priceService.stream.listen((tick) {
      add(FavouritePriceUpdated(tick: tick));
    });

    on<LoadFavouritesEvent>(loadFavouritesEvent);
    on<FavouritePriceUpdated>(favouritePriceUpdated);
    on<RemoveFromFavourites>(removeFromFavourites);
    on<FavouritesSearchEvent>(_onSearch);
  }

  void _applyCachedPrices() {
    final latest = _priceService.latestTicks;

    String norm(String s) => s.replaceAll('/', '');

    _favouritesCache = _favouritesCache.map((item) {
      final tick = latest[norm(item.symbol)];

      if (tick != null) {
        return item.copyWith(
          cmp: tick.last,
          low: tick.bid,
          high: tick.ask,
        );
      }

      return item;
    }).toList();
  }

  /* ---------------- LOAD ---------------- */

  FutureOr<void> loadFavouritesEvent(LoadFavouritesEvent event, Emitter<FavouritesBlocState> emit) async {
    if (event.showLoading) {
      emit(FavouritesLoading());
    }

    await WalletService.updateAccountService();

    try {
      final user = await TokenStorageService.getUser();

      if (user == null) {
        emit(FavouritesError(message: 'Unable to load favourites'));
        return;
      }

      final accountType = getIt<MyAccountService>().accountType;

      final url = accountType == AccountType.demo
          ? baseUrl + fetchDemoFavouritePairs + user.userId.toString()
          : baseUrl + fetchFavouritePairs + user.userId.toString();

      final response = await dio.get(url);

      final favouritesResponse = FavouritesResponse.fromJson(response.data);

      if (!favouritesResponse.success) {
        emit(FavouritesError(message: favouritesResponse.message ?? 'Unable to load favourites'));
        return;
      }

      _favouritesCache = favouritesResponse.favourites;

      // Apply cached prices
      _applyCachedPrices();

      _filterAndEmit(emit);
    } catch (e) {
      emit(FavouritesError(message: 'Unable to load favourites'));
    }
  }

  /* ---------------- PRICE UPDATE ---------------- */

  FutureOr<void> favouritePriceUpdated(FavouritePriceUpdated event, Emitter<FavouritesBlocState> emit) {
    final tick = event.tick;

    String norm(String s) => s.replaceAll('/', '');

    _favouritesCache = _favouritesCache.map((item) {
      if (norm(item.symbol) == norm(tick.symbol)) {
        return item.copyWith(cmp: tick.last, low: tick.bid, high: tick.ask);
      }

      return item;
    }).toList();

    _filterAndEmit(emit);
  }

  /* ---------------- SEARCH ---------------- */

  void _onSearch(FavouritesSearchEvent event, Emitter<FavouritesBlocState> emit) {
    _currentSearchQuery = event.query;
    _filterAndEmit(emit);
  }

  void _filterAndEmit(Emitter<FavouritesBlocState> emit) {
    if (_currentSearchQuery.isEmpty) {
      emit(FavouritesLoaded(favourites: _favouritesCache, originalFavourites: _favouritesCache));
      return;
    }

    final normalizedQuery = _currentSearchQuery.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

    final filtered = _favouritesCache.where((item) {
      final normalizedSymbol = item.symbol.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

      return normalizedSymbol.contains(normalizedQuery);
    }).toList();

    emit(FavouritesLoaded(favourites: filtered, originalFavourites: _favouritesCache));
  }

  /* ---------------- REMOVE ---------------- */

  FutureOr<void> removeFromFavourites(RemoveFromFavourites event, Emitter<FavouritesBlocState> emit) async {
    final user = getIt<MyAccountService>().user!;

    try {
      final accountType = getIt<MyAccountService>().accountType;

      final url = accountType == AccountType.demo ? baseUrl + removeDemoFavourite : baseUrl + removeFavourite;

      final response = await dio.delete(url, data: {'symbol': event.symbol, 'user_id': user.userId.toString()});

      final parsed = FavouritesResponse.fromJson(response.data);

      if (!parsed.success) {
        emit(FavouritesError(message: parsed.message ?? 'Error removing'));
        return;
      }

      emit(SuccessfulllyRemovedFromFavourites(message: parsed.message ?? 'Removed successfully'));
    } catch (e) {
      emit(FavouritesError(message: 'Error removing from favourites'));
    }
  }

  /* ---------------- CLEANUP ---------------- */

  @override
  Future<void> close() {
    _priceSub.cancel();
    return super.close();
  }
}
