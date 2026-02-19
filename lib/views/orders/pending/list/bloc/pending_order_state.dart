part of 'pending_order_bloc.dart';

@immutable
sealed class PendingOrderState {}

final class PendingOrderInitial extends PendingOrderState {}

final class Loading extends PendingOrderState {}

final class Error extends PendingOrderState {
  final String message;
  Error({required this.message});
}


final class PendingOrdersLoaded extends PendingOrderState {
  final List<TradeOrder> orders;

  PendingOrdersLoaded({required this.orders});
}


