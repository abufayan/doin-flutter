// ignore_for_file: depend_on_referenced_packages

import 'package:meta/meta.dart';

@immutable
sealed class AccountBlocState {}

// INITIAL STATES

final class AccountBlocInitial extends AccountBlocState {}

final class AccountBlocLoading extends AccountBlocState {}

// SUCCESS STATES 

final class MyAccountDataLoaded extends AccountBlocState {
  final String bannerImage;
  final String walletBalance;
  final bool kycVerified;
  // final String accountType; // 'real' or 'demo'

  MyAccountDataLoaded({
    required this.bannerImage,
    required this.walletBalance,
    required this.kycVerified
  });
}

final class AuthBlocActionState extends  AccountBlocState {

}

final class AccountBlocFailure extends AuthBlocActionState {
  final String error;
  AccountBlocFailure({required this.error});

}


final class AccountSwitchError extends AccountBlocState {
  final String message;

  AccountSwitchError({required this.message});
}
