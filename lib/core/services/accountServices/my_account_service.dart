import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/datamodel/user_model.dart';

abstract class MyAccountService {
  UserModel? get user;
  
  double? get wallet;

  double? get usedMargin;

  AccountType? get accountType;

  Future<void> initialize();


  Future<void> setValues({required String gotWallet, required  String usedMargin});

  Future<void> updateAccountType(AccountType type);
}