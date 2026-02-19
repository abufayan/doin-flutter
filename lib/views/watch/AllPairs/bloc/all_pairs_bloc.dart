import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/datamodel/pair_response.dart';
import 'package:doin_fx/core/services/wallet_service.dart';
import 'package:doin_fx/setup.dart';
import 'package:meta/meta.dart';

part 'all_pairs_bloc_event.dart';
part 'all_pairs_bloc_state.dart';

class AllPairsBloc extends Bloc<AllPairsBlocEvent, AllPairsBlocState> {
  List<PairItem> _allPairsCache = [];

  AllPairsBloc() : super(AllPairsBlocInitial()) {
    on<AllPairsLoadEvent>(allPairsLoadEvent);
    on<AddToFavouriteEvent>(addToFavouriteEvent);
    on<AllPairsSearchEvent>(_onSearch);
  }

  FutureOr<void> allPairsLoadEvent(AllPairsLoadEvent event, Emitter<AllPairsBlocState> emit) async {
    emit(LoadingPairs());

    try {
      final response = await dio.get(baseUrl + fetchAllPairs);

      final pairResponse = PairResponse.fromJson(response.data);

      if (pairResponse.message.toLowerCase().contains('success')) {
        _allPairsCache = pairResponse.pairs;
        emit(AllPairsLoaded(pairs: pairResponse.pairs, originalPairs: _allPairsCache));
      } else {
        emit(ErrorLoadingPairs(message: pairResponse.message));
      }
    } on DioException catch (e) {
      final message = (e.response?.data is Map)
          ? e.response?.data['message']?.toString() ?? 'Error fetching pairs'
          : 'Error fetching pairs';
      emit(ErrorLoadingPairs(message: message));
    } catch (e) {
      emit(ErrorLoadingPairs(message: 'Error fetching pairs: ${e.toString()}'));
    }
  }

  void _onSearch(AllPairsSearchEvent event, Emitter<AllPairsBlocState> emit) {
    if (event.query.isEmpty) {
      emit(AllPairsLoaded(pairs: _allPairsCache, originalPairs: _allPairsCache));
      return;
    }

    final normalizedQuery = event.query.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

    final filtered = _allPairsCache.where((pair) {
      final normalizedSymbol = pair.symbol.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      return normalizedSymbol.contains(normalizedQuery);
    }).toList();

    emit(AllPairsLoaded(pairs: filtered, originalPairs: _allPairsCache));
  }

  FutureOr<void> addToFavouriteEvent(AddToFavouriteEvent event, Emitter<AllPairsBlocState> emit) async {
    await WalletService.updateAccountService();
    try {
      final myAccount = getIt<MyAccountService>();
      if (myAccount.user == null) {
        emit(AllPairsFavouritesError(message: 'User not authenticated'));
        return;
      }

      final symbol = event.pair.symbol.replaceAll(RegExp(r'[\\/]+'), '');

      final accountType = myAccount.accountType;
      final url = accountType == AccountType.demo ? baseUrl + addtoDemoFavourite : baseUrl + addtoFavourite;

      final response = await dio.post(url, data: {'symbol': symbol, 'user_id': myAccount.user!.userId});

      final pairResponse = FavoritesResponse.fromJson(response.data);

      if (pairResponse.success) {
        emit(FavouritesAddedSuccessfully(message: pairResponse.message));
      }
    } on DioException catch (e) {
      final message = (e.response?.data is Map)
          ? e.response?.data['message']?.toString() ?? 'Error adding to favourites'
          : 'Error adding to favourites';
      emit(AllPairsFavouritesError(message: message));
    } catch (e) {
      emit(AllPairsFavouritesError(message: 'Error adding to favourites: ${e.toString()}'));
    }
  }
}
