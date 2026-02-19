part of 'deposit_methods_bloc.dart';

@immutable
abstract class DepositMethodsState {}

class DepositMethodsInitial extends DepositMethodsState {}

class DepositMethodsLoading extends DepositMethodsState {}

class DepositMethodsLoaded extends DepositMethodsState {
  final List<PaymentMethodItem> methods;

  DepositMethodsLoaded({required this.methods});
}

class DepositMethodsError extends DepositMethodsState {
  final String message;

  DepositMethodsError({required this.message});
}

class DepositMethodsEmpty extends DepositMethodsState {}
