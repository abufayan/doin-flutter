part of 'pending_order_bloc.dart';

@immutable
sealed class PendingOrderEvent {}

class LoadPendingOrders extends PendingOrderEvent {}

final class ConnectSocket extends PendingOrderEvent {}

