part of 'deposit_history_bloc.dart';

@immutable
abstract class DepositHistoryEvent {}

/// Load deposit history for current user
class LoadDepositHistory extends DepositHistoryEvent {
  final bool showLoading;

  LoadDepositHistory({this.showLoading = true});
}

/// Refresh deposit history (pull-to-refresh)
class RefreshDepositHistory extends DepositHistoryEvent {}

class FilterDepositHistory extends DepositHistoryEvent {
  final String searchQuery;
  final DateTimeRange? dateRange;

  FilterDepositHistory({
    this.searchQuery = '',
    this.dateRange,
  });
}
