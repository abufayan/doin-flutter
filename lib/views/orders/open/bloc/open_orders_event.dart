part of 'open_orders_bloc.dart';

@immutable
sealed class OpenOrdersEvent {}

class LoadOpenOrders extends OpenOrdersEvent {}

final class ConnectSocket extends OpenOrdersEvent {}

class PriceUpdated extends OpenOrdersEvent {
  final String symbol;
  final double cmp;
  final double low;
  final double high;

  PriceUpdated({
    required this.symbol,
    required this.cmp,
    required this.low,
    required this.high
  });
}