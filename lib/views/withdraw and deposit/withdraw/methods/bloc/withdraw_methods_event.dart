part of 'withdraw_methods_bloc.dart';

@immutable
abstract class WithdrawMethodsEvent {}

/// Load active withdrawal methods from API
class LoadWithdrawMethods extends WithdrawMethodsEvent {}

/// Refresh withdrawal methods
class RefreshWithdrawMethods extends WithdrawMethodsEvent {}
