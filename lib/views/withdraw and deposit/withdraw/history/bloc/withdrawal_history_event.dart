part of 'withdrawal_history_bloc.dart';

@immutable
abstract class WithdrawalHistoryEvent {}

/// Load withdrawal history for current user
class LoadWithdrawalHistory extends WithdrawalHistoryEvent {
  final bool showLoading;

  LoadWithdrawalHistory({this.showLoading = true});
}

/// Refresh withdrawal history (pull-to-refresh)
class RefreshWithdrawalHistory extends WithdrawalHistoryEvent {}

class FilterWithdrawalHistory extends WithdrawalHistoryEvent {
  final String searchQuery;
  final DateTimeRange? dateRange;

  FilterWithdrawalHistory({
    this.searchQuery = '',
    this.dateRange,
  });
}
