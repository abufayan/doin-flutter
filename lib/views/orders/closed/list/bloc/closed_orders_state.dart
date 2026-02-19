part of 'closed_orders_bloc.dart';

@immutable
sealed class ClosedOrdersState {}

final class ClosedOrdersInitial extends ClosedOrdersState {}

final class Loading extends ClosedOrdersState {}

final class ClosedOrdersLoaded extends ClosedOrdersState {
  final List<TradeOrder> orders;

  ClosedOrdersLoaded({required this.orders});

}

final class Error extends ClosedOrdersState {
  final String message;

  Error({required this.message});
}

final class ActionSuccess extends ClosedOrdersState {
  final String message;
  ActionSuccess(this.message);
}
