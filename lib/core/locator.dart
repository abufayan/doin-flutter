import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service_implementation.dart';
import 'package:get_it/get_it.dart';
// import 'my_account_service.dart';
// import 'my_account_service_impl.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  getIt.registerLazySingleton<MyAccountService>(
    () => MyAccountServiceImpl(),
  );
}
