import 'package:doin_fx/core/enums.dart';
import 'package:meta/meta.dart';



@immutable
sealed class HomeState {
  final int index;
  final AccountType accountType;
  const HomeState(this.index, {this.accountType = AccountType.live});
}

final class HomeInitial extends HomeState {
  const HomeInitial() : super(0, accountType: AccountType.live);
}

final class HomeTabChanged extends HomeState {
  const HomeTabChanged(int index, {AccountType accountType = AccountType.live})
      : super(index, accountType: accountType);
}

final class AccountSwitched extends HomeState {
  final bool isLoading;
  final String? errorMessage;

  const AccountSwitched(
    int index, {
    required AccountType accountType,
    this.isLoading = false,
    this.errorMessage,
  }) : super(index, accountType: accountType);
}
