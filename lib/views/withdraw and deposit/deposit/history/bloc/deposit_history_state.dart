part of 'deposit_history_bloc.dart';

@immutable
abstract class DepositHistoryState {}

class DepositHistoryInitial extends DepositHistoryState {}

class DepositHistoryLoading extends DepositHistoryState {}

class DepositHistoryLoaded extends DepositHistoryState {
  final List<DepositHistoryItem> deposits;          // original list
  final List<DepositHistoryItem> filteredDeposits;  // filtered list
  final double totalAmount;

  DepositHistoryLoaded({
    required this.deposits,
    required this.filteredDeposits,
    required this.totalAmount,
  });
}

class DepositHistoryError extends DepositHistoryState {
  final String message;

  DepositHistoryError({required this.message});
}

class DepositHistoryEmpty extends DepositHistoryState {}


