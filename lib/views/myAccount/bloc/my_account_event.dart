import 'package:meta/meta.dart';

@immutable
sealed class MyAccountEvent {}

/// Load all account data on screen init
// final class LoadMyAccountData extends MyAccountEvent {
//   final int userId;
//   LoadMyAccountData({required this.userId});
// }

/// Event to refresh only the account balance
final class LoadMyAccount extends MyAccountEvent {
  // final int userId;
  LoadMyAccount();
}




