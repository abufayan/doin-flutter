part of 'deposit_bloc.dart';

@immutable
sealed class DepositEvent {}

final class LoadInitialValues extends DepositEvent {
}

final class OnSubmit extends DepositEvent {
  final String paymentMethod; // 'upi' or 'usdt'
  final String transactionId;
  final String enterAmount;
  final String? upiId;
  final File? paymentScreenshot;

  OnSubmit({
    required this.paymentMethod,
    required this.transactionId,
    required this.enterAmount,
    this.upiId,
    this.paymentScreenshot,
  });
}
