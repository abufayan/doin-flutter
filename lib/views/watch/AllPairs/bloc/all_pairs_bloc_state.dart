part of 'all_pairs_bloc.dart';

@immutable
sealed class AllPairsBlocState {}

final class AllPairsBlocInitial extends AllPairsBlocState {}

final class LoadingPairs extends AllPairsBlocState {}

final class AllPairsLoaded extends AllPairsBlocState {
  final List<PairItem> pairs;
  final List<PairItem> originalPairs;

  AllPairsLoaded({required this.pairs, List<PairItem>? originalPairs})
    : originalPairs = originalPairs ?? pairs;
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

final class AllPairsFavouritesError extends AllPairsBlocActionState {
  final String message;
  AllPairsFavouritesError({required this.message});
}
