part of 'deposit_methods_bloc.dart';

@immutable
abstract class DepositMethodsEvent {}

/// Load active deposit methods from API
class LoadDepositMethods extends DepositMethodsEvent {}

/// Refresh deposit methods
class RefreshDepositMethods extends DepositMethodsEvent {}
