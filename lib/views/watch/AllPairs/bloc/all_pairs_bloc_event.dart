part of 'all_pairs_bloc.dart';

@immutable
sealed class AllPairsBlocEvent {}

final class AllPairsLoadEvent extends AllPairsBlocEvent {}

final class AddToFavouriteEvent extends AllPairsBlocEvent {
  final PairItem pair;
  AddToFavouriteEvent({required this.pair});
}