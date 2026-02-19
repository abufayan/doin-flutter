part of 'withdraw_methods_bloc.dart';

@immutable
abstract class WithdrawMethodsState {}

class WithdrawMethodsInitial extends WithdrawMethodsState {}

class WithdrawMethodsLoading extends WithdrawMethodsState {}

class WithdrawMethodsLoaded extends WithdrawMethodsState {
  final List<PaymentMethodItem> methods;

  WithdrawMethodsLoaded({required this.methods});
}

class WithdrawMethodsError extends WithdrawMethodsState {
  final String message;

  WithdrawMethodsError({required this.message});
}

class WithdrawMethodsEmpty extends WithdrawMethodsState {}
