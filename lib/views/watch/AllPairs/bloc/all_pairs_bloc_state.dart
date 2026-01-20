part of 'all_pairs_bloc.dart';

@immutable
sealed class AllPairsBlocState {}

final class AllPairsBlocInitial extends AllPairsBlocState {}

final class LoadingPairs extends AllPairsBlocState {}

final class AllPairsLoaded extends AllPairsBlocState {
  final List<PairItem> pairs;

  AllPairsLoaded({required this.pairs});
}

final class AllPairsBlocActionState extends AllPairsBlocState {}

final class ErrorLoadingPairs extends AllPairsBlocActionState {
  final String message;

  ErrorLoadingPairs({required this.message});
}

final class FavouritesAddedSuccessfully extends AllPairsBlocActionState {
  final String message;
  FavouritesAddedSuccessfully({required this.message});
}