part of 'open_orders_bloc.dart';

@immutable
sealed class OpenOrdersState {}

final class OpenOrdersInitial extends OpenOrdersState {}

final class OpenOrdersLoading extends OpenOrdersState {}

final class OpenOrdersLoaded extends OpenOrdersState {
  final List<OpenOrder> orders;

  final double balance;
  final double usedMargin;

  final double totalPnl;
  final double equity;
  final double freeMargin;
  final double marginLevel;

  OpenOrdersLoaded({
    required this.orders,
    required this.balance,
    required this.usedMargin,
    required this.totalPnl,
    required this.equity,
    required this.freeMargin,
    required this.marginLevel,
  });

  OpenOrdersLoaded copyWith({
    List<OpenOrder>? orders,
    double? totalPnl,
    double? balance,
    double? equity,
    double? usedMargin,
    double? freeMargin,
    double? marginLevel,
  }) {
    return OpenOrdersLoaded(
      orders: orders ?? this.orders,
      totalPnl: totalPnl ?? this.totalPnl,
      balance: balance ?? this.balance,
      equity: equity ?? this.equity,
      usedMargin: usedMargin ?? this.usedMargin,
      freeMargin: freeMargin ?? this.freeMargin,
      marginLevel: marginLevel ?? this.marginLevel,
    );
  }
}


final class OpenOrdersError extends OpenOrdersState {
  final String message;

  OpenOrdersError({required this.message});
}
