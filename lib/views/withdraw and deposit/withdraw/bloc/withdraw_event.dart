part of 'withdraw_bloc.dart';

@immutable
sealed class WithdrawEvent {}

final class LoadInitialValues extends WithdrawEvent {}

final class OnWithdraw extends WithdrawEvent {
  final String paymentMethod; // 'upi' or 'usdt'
  final String paymentAddress;
  final String requestedAmount;
  final String? upiId;
  final File? paymentScreenshot;

  OnWithdraw({
    required this.paymentMethod,
    required this.paymentAddress,
    required this.requestedAmount,
    this.upiId,
    this.paymentScreenshot,
  });
}
