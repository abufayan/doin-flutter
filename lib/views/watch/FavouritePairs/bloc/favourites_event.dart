part of 'favourites_bloc.dart';

@immutable
sealed class FavouritesEvent {}

final class LoadFavouritesEvent extends FavouritesEvent {}

final class ConnectSocketEvent extends FavouritesEvent {}

class FavouritePriceUpdated extends FavouritesEvent {
  final String symbol;
  final double cmp;
  final double low;
  final double high;

  FavouritePriceUpdated({
    required this.symbol,
    required this.cmp,
    required this.low,
    required this.high
  });
}




