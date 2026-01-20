import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/DrawerTabs/support/bloc/support_bloc.dart';
import 'package:doin_fx/views/auth/bloc/auth_bloc.dart';
import 'package:doin_fx/views/myAccount/bloc/my_account_bloc.dart';
import 'package:doin_fx/views/trade/bloc/trade_bloc.dart';
import 'package:doin_fx/views/watch/AllPairs/bloc/all_pairs_bloc.dart';
import 'package:doin_fx/views/watch/FavouritePairs/bloc/favourites_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/utils/symbol_icon_resolver.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  await getIt<MyAccountService>().initialize();
  await debugAsset();
  runApp(const DoinFx());
}

class DoinFx extends StatefulWidget {
  const DoinFx({super.key});

  @override
  State<DoinFx> createState() => _DoinFxState();
}

class _DoinFxState extends State<DoinFx> {
  late final AuthBloc _authBloc;
  late final MyAccountBloc _myAccountBloc;
  late final TradeBloc _tradeScreen;
  late final AllPairsBloc _allPairsBloc;
  late final FavouritesBloc _favouritesBloc;
  late final SupportBloc _supportBLoc;
  
  


  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _myAccountBloc = MyAccountBloc();
    _tradeScreen = TradeBloc();
    _allPairsBloc = AllPairsBloc();
    _favouritesBloc  = FavouritesBloc();
    _supportBLoc = SupportBloc();
    // Check authentication status when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authBloc.add(CheckAuthStatus());
    });
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
           BlocProvider.value(value: _authBloc),
           BlocProvider.value(value: _myAccountBloc),
           BlocProvider.value(value: _tradeScreen),
           BlocProvider.value(value: _allPairsBloc),
           BlocProvider.value(value: _favouritesBloc),
           BlocProvider.value(value: _supportBLoc)
      ],
      child: MaterialApp.router( 
        title: 'Doin FX',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),  
          useMaterial3: true,
        ),
        routerConfig: appRouter.config(
          navigatorObservers: () => [],
        ),
      ),
    );
  }
}
