import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/datamodel/pair_response.dart';
import 'package:doin_fx/setup.dart';
import 'package:meta/meta.dart';

part 'all_pairs_bloc_event.dart';
part 'all_pairs_bloc_state.dart';

class AllPairsBloc extends Bloc<AllPairsBlocEvent, AllPairsBlocState> {
  AllPairsBloc() : super(AllPairsBlocInitial()) {
    on<AllPairsBlocEvent>((event, emit) { });
    on<AllPairsLoadEvent>(allPairsLoadEvent);
    on<AddToFavouriteEvent>(addToFavouriteEvent);
  }

  FutureOr<void> allPairsLoadEvent(
    AllPairsLoadEvent event,
    Emitter<AllPairsBlocState> emit,
  ) async {
    emit(LoadingPairs());

    try {
      final response = await dio.get(baseUrl + fetchAllPairs);

      final pairResponse = PairResponse.fromJson(response.data);

      if (pairResponse.message.toLowerCase().contains('success')) {
        emit(AllPairsLoaded(pairs: pairResponse.pairs));
      } else {
        emit(ErrorLoadingPairs(message: pairResponse.message));
      }
    } catch (e) {
      emit(ErrorLoadingPairs(message: 'Error fetching pairs: ${e.toString()}'));
    }
  }

  FutureOr<void> addToFavouriteEvent(
      AddToFavouriteEvent event,
      Emitter<AllPairsBlocState> emit, // ← here
      ) async {
    try {

      String _symbol = event.pair.symbol.replaceAll(RegExp(r'[\\/]+'), '');
      final response = await dio.post(
        baseUrl + addtoFavourite,
        data: {
          'symbol': _symbol,
          'user_id': getIt<MyAccountService>().user!.userId,
        },
      );

      // Parse the response JSON
      final pairResponse = FavoritesResponse.fromJson(response.data);

      if (pairResponse.success) {
        emit(FavouritesAddedSuccessfully(message: pairResponse.message));
      }
    } catch (e, st) {
      print('Error adding to favorites: $e');
      print(st);
    }
  }
}
