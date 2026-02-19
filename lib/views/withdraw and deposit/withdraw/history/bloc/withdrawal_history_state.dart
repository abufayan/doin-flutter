part of 'withdrawal_history_bloc.dart';

@immutable
abstract class WithdrawalHistoryState {}

class WithdrawalHistoryInitial extends WithdrawalHistoryState {}

class WithdrawalHistoryLoading extends WithdrawalHistoryState {}

class WithdrawalHistoryLoaded extends WithdrawalHistoryState {
  final List<WithdrawalHistoryItem> withdrawals;

  WithdrawalHistoryLoaded({
    required this.withdrawals,
  });
}

class WithdrawalHistoryError extends WithdrawalHistoryState {
  final String message;

  WithdrawalHistoryError({required this.message});
}

class WithdrawalHistoryEmpty extends WithdrawalHistoryState {}
