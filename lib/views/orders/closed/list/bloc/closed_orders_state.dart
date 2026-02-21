part of 'closed_orders_bloc.dart';

@immutable
sealed class ClosedOrdersState {}

final class ClosedOrdersInitial extends ClosedOrdersState {}

final class Loading extends ClosedOrdersState {}

final class ClosedOrdersLoaded extends ClosedOrdersState {
  final List<TradeOrder> orders;
  final ClosedOrderTypes filterType;

  ClosedOrdersLoaded({required this.orders, this.filterType = ClosedOrderTypes.last24hrs});

}

final class Error extends ClosedOrdersState {
  final String message;

  Error({required this.message});
}

final class ActionSuccess extends ClosedOrdersState {
  final String message;
  ActionSuccess(this.message);
}
