part of 'favourites_bloc.dart';

@immutable
abstract class FavouritesEvent {}

class LoadFavouritesEvent extends FavouritesEvent {
  final bool showLoading;

  LoadFavouritesEvent({this.showLoading = true});
}

class FavouritesSearchEvent extends FavouritesEvent {
  final String query;
  FavouritesSearchEvent(this.query);
}

final class ConnectSocketEvent extends FavouritesEvent {}

class FavouritePriceUpdated extends FavouritesEvent {
  final PriceTick tick;

  FavouritePriceUpdated({required this.tick});
}

final class RemoveFromFavourites extends FavouritesEvent {
  final String symbol;

  RemoveFromFavourites({required this.symbol});
}
