// ignore_for_file: override_on_non_overriding_member

import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/services/token_storage_service.dart';
import 'package:doin_fx/datamodel/user_model.dart';

import 'my_account_service.dart';
// import 'token_storage_service.dart';

class MyAccountServiceImpl implements MyAccountService {
  UserModel? _user;

  double? _wallet;

  double? _usedMargin;

  AccountType? _accountType;

  @override
  UserModel? get user => _user;

  @override
  double? get wallet => _wallet;

  @override
  double? get usedMargin => _usedMargin;

  @override
  AccountType? get accountType => _accountType;

  @override
  Future<void> initialize() async {
    final user = await TokenStorageService.getUser();
    final token = await TokenStorageService.getToken();

    print('User Token: $token');
    print('''
        User Type : ${user?.accountType}
        User id   : ${user?.userId}
        Mail      : ${user?.email}   
        Name      : ${user?.username} 
        ''');

    _user = user; // <-- safe even if null
    if (user != null) {
      _accountType = (user.accountType ?? "").toUpperCase() == "LIVE"
          ? AccountType.live
          : AccountType.demo;
    }
  }

  @override
  Future<void> setValues({
    required String gotWallet,
    required String usedMargin,
  }) async {
    _wallet = double.parse(gotWallet);
    _accountType = (user!.accountType ?? "").toUpperCase() == "LIVE"
        ? AccountType.live
        : AccountType.demo;
    _usedMargin = double.parse(usedMargin);
  }

  @override
  Future<void> updateAccountType(AccountType type) async {
    _accountType = type;
    if (_user != null) {
      _user = _user!.copyWith(
        accountType: type == AccountType.live ? "LIVE" : "DEMO",
      );
    }
  }
}
