part of 'detail_pending_bloc.dart';

@immutable
sealed class DetailPendingState {}

final class DetailPendingInitial extends DetailPendingState {}

final class Loading extends DetailPendingState {}

class UpdateTradeSuccess extends DetailPendingState {
  final String message;
  UpdateTradeSuccess({required this.message});
}

class RemoveTpSlSuccess extends DetailPendingState {
  final String message;
  final bool removedTp;
  final bool removedSl;
  RemoveTpSlSuccess({required this.message, this.removedTp = false, this.removedSl = false});
}

class UpdateTradeError extends DetailPendingState {
  final String message;
  UpdateTradeError({required this.message});
}

class TradeClosed extends DetailPendingState {
  final String message;
  TradeClosed({required this.message});
}
