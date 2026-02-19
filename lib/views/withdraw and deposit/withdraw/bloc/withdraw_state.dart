part of 'withdraw_bloc.dart';

@immutable
sealed class WithdrawState {}

final class WithdrawInitial extends WithdrawState {}

final class WithdrawLoading extends WithdrawState {}

final class WithdrawSuccess extends WithdrawState {
  final WithdrawApiResponse response;

  WithdrawSuccess({required this.response});
}

final class WithdrawFailure extends WithdrawState {
  final String message;
  final String? error;

  WithdrawFailure({required this.message, this.error});
}

final class WithDrawLoaded extends WithdrawState {
  final PaymentConfigResponse minimumValues;
  WithDrawLoaded({required this.minimumValues});
}