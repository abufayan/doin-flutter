// ignore_for_file: empty_catches, prefer_interpolation_to_compose_strings

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/core/services/token_storage_service.dart';
import 'package:doin_fx/datamodel/account_response.dart';
import 'package:doin_fx/datamodel/user_model.dart';
import 'package:doin_fx/setup.dart';
import 'package:get_it/get_it.dart';
// import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'my_account_event.dart';
import 'my_account_state.dart';

class MyAccountBloc extends Bloc<MyAccountEvent, AccountBlocState> {
  MyAccountBloc() : super(AccountBlocInitial()) {
    // Load all data
    on<LoadMyAccount>(_loadMyAccount);
  }


  Future<void> _loadMyAccount(LoadMyAccount event, Emitter<AccountBlocState> emit) async {
        emit(AccountBlocLoading());

        try {
          // if(getIt<MyAccountService>().user == null) {
          //   await getIt<MyAccountService>().initialize();
          // }
          
          final String image = await loadBanner();
          final WalletResponse? wallet = await loadWalletBalance()!;

          await getIt<MyAccountService>().setValues(
              gotWallet: wallet!.wallet.toStringAsFixed(2),
              usedMargin: wallet!.used_margin.toString());

          await getIt<MyAccountService>().initialize();

          if(image != '' && wallet != null) {
            emit(MyAccountDataLoaded(
              bannerImage: image,
              walletBalance: wallet.wallet.toStringAsFixed(2),
              kycVerified: await loadKycStatus()
              ));
          }
        } catch (e, stackTrace) {
          emit(AccountBlocFailure(error: e.toString()));
        }
  }
}

var myAccount = getIt<MyAccountService>();

Future<String> loadBanner () async { 
   try {
    final response = await dio.get(baseUrl + bannerUrl);

    final data = BannerResponse.fromJson(response.data);


    if (data.success && data.banners.isNotEmpty) {
      return data.banners.first.image;
    }
  } catch (e, stackTrace) {
    // print('loadBanner error: $e');
    // print(stackTrace);
  }

  return '';
}

Future<WalletResponse?> loadWalletBalance () async {
   try {
    // Get the latest user data from storage to check account type
    final user = await TokenStorageService.getUser();
    if (user == null) return null;
    
    final userId = user.userId.toString();
    final accountType = (user.accountType ?? 'LIVE').toUpperCase();
    
    // Use different URL based on account type
    final url = accountType == 'DEMO' 
        ? baseUrl + getDemoWalletBalance + userId
        : baseUrl + getRealWalletBalance + userId;
    
    final response = await dio.get(url);

    final WalletResponse wallet = WalletResponse.fromJson(response.data);

    // print('url : $url');

    if (wallet.status == 'success') {
      return wallet;
    }
  } catch (e, stackTrace) {}

  return null;
}

Future<bool> loadKycStatus() async {
  try {
    final response = await dio.get(
      baseUrl + kycVerified + '${myAccount.user!.userId}',
    );

    final List data = response.data as List;

    if (data.isEmpty) return false;

    final kyc = KycResponse.fromJson(data.first);

    return kyc.isApproved;
  } catch (e, stackTrace) {
  }

  return false;
}
