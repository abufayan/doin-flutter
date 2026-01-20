import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/core/services/token_storage_service.dart';
import 'package:doin_fx/datamodel/pair_response.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/watch/FavouritePairs/bloc/favourites_state.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

part 'favourites_event.dart';
// part 'watch_list_bloc_state.dart';

class FavouritesBloc extends Bloc<FavouritesEvent, FavouritesBlocState> {
  IO.Socket? _socket;

  FavouritesBloc() : super(FavouritesBlocInitial()) {
    on<LoadFavouritesEvent>(loadFavouritesEvent);
    on<ConnectSocketEvent>(connectSocketEvent);
    on<FavouritePriceUpdated>(favouritePriceUpdated);
  }

  FutureOr<void> loadFavouritesEvent(
    LoadFavouritesEvent event,
    Emitter<FavouritesBlocState> emit,
  ) async {
    emit(FavouritesLoading());

    try {
      final user = await TokenStorageService.getUser();

      if (user == null) {
        emit(FavouritesError(message: 'Unable to load favourites'));
        return;
      }

      final response = await dio.get(
        baseUrl + fetchFavouritePairs + user.userId.toString(),
      );

      final favouritesResponse = FavouritesResponse.fromJson(response.data);

      if (favouritesResponse.success) {
        emit(FavouritesLoaded(favourites: favouritesResponse.favourites));
      }

        if (!favouritesResponse.success) {
          emit(FavouritesError(
            message: favouritesResponse.message ?? 'Unable to load favourites',
          ));
          return;
        }

    } catch (e) {
      String errorMessage = 'Something went wrong';

      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        if (statusCode == 401 || statusCode == 403) {
          errorMessage = 'Session expired, Kindly login to continue';
        } else if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? errorMessage;
        }
      }

      emit(FavouritesError(message: errorMessage));
    }
  }

  FutureOr<void> connectSocketEvent(
      ConnectSocketEvent event,
      Emitter<FavouritesBlocState> emit,
      ) async {
    if (_socket != null) {
      print('⚠️ Socket already initialized, skipping');
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
      print('✅ Connected to socket');
      _socket!.send(['40']);
    });

    _socket!.onAny((event, data) {
      if (event == 'forex_update' && data is Map) {
        final symbol = data['symbol'] as String?;
        final price = data['p'];
        final low = data['a'];
        final high = data['b'];

        if (symbol != null && price != null) {
          add(FavouritePriceUpdated(
            symbol: symbol,
            cmp: (price as num).toDouble(),
            low: (low as num).toDouble(),
            high: (high as num).toDouble(),
          ));
        }
      }
    });

    _socket!.onDisconnect((_) => print('❌ Socket disconnected'));
    _socket!.onError((e) => print('⚠️ Socket error: $e'));

    _socket!.connect();
  }

  FutureOr<void> favouritePriceUpdated(FavouritePriceUpdated event, Emitter<FavouritesBlocState> emit) {

    String _norm(String s) => s.replaceAll('/', '');
     final currentState = state;

      if (currentState is FavouritesLoaded) {
        final updatedList = currentState.favourites.map((item) {
          if (_norm(item.symbol) == _norm(event.symbol)) {
            return item.copyWith(cmp: event.cmp, low: event.low, high: event.high);
          }
          return item;
        }).toList();

        emit(FavouritesLoaded(favourites: updatedList));
      }
  }

  @override
Future<void> close() {
  _socket?.dispose();
  return super.close();
}
}
