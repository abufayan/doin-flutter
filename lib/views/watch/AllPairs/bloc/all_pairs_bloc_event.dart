part of 'all_pairs_bloc.dart';

@immutable
abstract class AllPairsBlocEvent {}

final class AllPairsLoadEvent extends AllPairsBlocEvent {}

final class AllPairsSearchEvent extends AllPairsBlocEvent {
  final String query;
  AllPairsSearchEvent(this.query);
}

final class AddToFavouriteEvent extends AllPairsBlocEvent {
  final PairItem pair;
  AddToFavouriteEvent({required this.pair});
}
