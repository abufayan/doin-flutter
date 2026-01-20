import 'package:doin_fx/datamodel/pair_response.dart';
import 'package:flutter/material.dart';

// part of 'favourites_bloc.dart';


@immutable
sealed class FavouritesBlocState {}

final class FavouritesBlocInitial extends FavouritesBlocState {}

final class FavouritesActionState extends FavouritesBlocState {}

final class FavouritesLoading extends FavouritesBlocState {}

final class FavouritesLoaded extends FavouritesBlocState {
  final List<FavouriteItem> favourites;

  FavouritesLoaded({required this.favourites});
}

final class FavouritesError extends FavouritesBlocState {
  final String message;

  FavouritesError({required this.message});
}


