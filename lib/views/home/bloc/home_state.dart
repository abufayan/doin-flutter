import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:meta/meta.dart';

@immutable
sealed class HomeState {
  final int index;
  final AccountType accountType;
  final String? selectedSymbol;
  const HomeState(this.index, {required this.accountType, this.selectedSymbol});
}

final class HomeInitial extends HomeState {
  HomeInitial()
    : super(
        0,
        accountType: getIt<MyAccountService>().accountType ?? AccountType.live,
      );
}

final class HomeTabChanged extends HomeState {
  const HomeTabChanged(
    super.index, {
    required super.accountType,
    super.selectedSymbol,
  });
}

final class AccountSwitched extends HomeState {
  final bool isLoading;
  final String? errorMessage;
  // String? selectedSymbol,

  const AccountSwitched(
    super.index, {
    required super.accountType,
    this.isLoading = false,
    this.errorMessage,
    super.selectedSymbol,
  });
}
