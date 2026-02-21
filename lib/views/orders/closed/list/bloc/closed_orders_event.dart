part of 'closed_orders_bloc.dart';

@immutable
sealed class ClosedOrdersEvent {}

class LoadClosedOrders extends ClosedOrdersEvent {
  final ClosedOrderTypes type;

  LoadClosedOrders({this.type = ClosedOrderTypes.last24hrs}); 
}


