part of 'deposit_bloc.dart';

@immutable
sealed class DepositState {}

final class DepositInitial extends DepositState {}

final class DepositLoading extends DepositState {}

final class DepositSuccess extends DepositState {
  final DepositResponseModel response;
  DepositSuccess({required this.response});
}

final class DepositFailure extends DepositState {
  final String message;
  final String? error;

  DepositFailure({required this.message, this.error});
}

final class DepositLoaded extends DepositState {
  final PaymentConfigResponse minimumValues;
  DepositLoaded({required this.minimumValues});
}