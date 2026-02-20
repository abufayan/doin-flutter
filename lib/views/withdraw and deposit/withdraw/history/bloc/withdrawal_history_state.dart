part of 'withdrawal_history_bloc.dart';

@immutable
abstract class WithdrawalHistoryState {}

class WithdrawalHistoryInitial extends WithdrawalHistoryState {}

class WithdrawalHistoryLoading extends WithdrawalHistoryState {}

class WithdrawalHistoryLoaded extends WithdrawalHistoryState {
  final List<WithdrawalHistoryItem> withdrawals;          // original
  final List<WithdrawalHistoryItem> filteredWithdrawals;  // filtered

  WithdrawalHistoryLoaded({
    required this.withdrawals,
    required this.filteredWithdrawals,
  });
}

class WithdrawalHistoryError extends WithdrawalHistoryState {
  final String message;

  WithdrawalHistoryError({required this.message});
}

class WithdrawalHistoryEmpty extends WithdrawalHistoryState {}
