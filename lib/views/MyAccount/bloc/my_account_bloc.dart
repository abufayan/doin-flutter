// ignore_for_file: empty_catches, prefer_interpolation_to_compose_strings

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/Market/marketService.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/core/services/token_storage_service.dart';
import 'package:doin_fx/datamodel/account_response.dart';
import 'package:doin_fx/datamodel/demo_fund_response.dart';
import 'package:doin_fx/setup.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/views/DrawerTabs/kyc/datamodel/kyc_model.dart';
// import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'my_account_event.dart';
import 'my_account_state.dart';

class MyAccountBloc extends Bloc<MyAccountEvent, AccountBlocState> {
  MyAccountBloc() : super(AccountBlocInitial()) {
    // Load all data
    on<LoadMyAccount>(_loadMyAccount);
    on<AddFundRequested>(_addFundRequested);
  }

  Future<void> _loadMyAccount(
      LoadMyAccount event,
      Emitter<AccountBlocState> emit,
      ) async {
    if (event.showLoading) {
      emit(AccountBlocLoading());
    }

    try {
      await getIt<MarketPriceService>().connect();

      final image = await loadBanner();
      final wallet = await loadWalletBalance();

      if (wallet == null) {
        emit(AccountBlocFailure(error: 'Failed to load wallet'));
        return;
      }

      await getIt<MyAccountService>().setValues(
        gotWallet: wallet.wallet.toStringAsFixed(2),
        usedMargin: wallet.used_margin.toString(),
      );

      emit(
        MyAccountDataLoaded(
          bannerImage: image, // can be empty, that's fine
          walletBalance: wallet.wallet.toStringAsFixed(2),
          kycVerified: await loadKycStatus(),
        ),
      );
    } catch (e) {
      emit(AccountBlocFailure(error: e.toString()));
    }
  }

  FutureOr<void> _addFundRequested(AddFundRequested event, Emitter<AccountBlocState> emit) async {
    // ── Validate amount ──
    final double? parsedAmount = double.tryParse(event.amount);
    if (parsedAmount == null || parsedAmount <= 0) {
      emit(AccountBlocFailure(error: 'Please enter a valid amount'));
      return;
    }

    // emit(AccountBlocLoading());

    try {
      final user = getIt<MyAccountService>().user;
      if (user == null) {
        emit(AccountBlocFailure(error: 'User not found. Please login again.'));
        return;
      }

      final response = await dio.post(
        baseUrl + updateDemoWallet,
        data: {'user_id': user.userId.toString(), 'balance': parsedAmount},
      );

      final result = DemoFundResponse.fromJson(response.data as Map<String, dynamic>);

      if (result.isSuccess) {
        emit(AddFundSuccess(message: result.message));
        // Refresh account data to show updated balance
        add(LoadMyAccount(showLoading: false));
      } else {
        emit(AccountBlocFailure(error: result.message));
      }
    } on DioException catch (e) {
      String message;
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        message = 'Connection timed out. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        message = 'No internet connection. Please check your network.';
      } else if (e.response?.data is Map) {
        message = e.response?.data['message']?.toString() ?? 'Failed to add funds';
      } else {
        message = 'Failed to add funds. Please try again.';
      }
      emit(AccountBlocFailure(error: message));
    } catch (e) {
      emit(AccountBlocFailure(error: 'Something went wrong: ${e.toString()}'));
    }
  }
}

var myAccount = getIt<MyAccountService>();

Future<String> loadBanner() async {
  try {
    final response = await dio.get(baseUrl + bannerUrl);

    final data = BannerResponse.fromJson(response.data);

    if (data.success && data.banners.isNotEmpty) {
      if (data.banners.length > 1 &&
          data.banners[1].image.isNotEmpty) {
        return data.banners[1].image;
      }

      if (data.banners[0].image.isNotEmpty) {
        return data.banners[0].image;
      }
    }
  } catch (e) {}

  return '';
}

Future<WalletResponse?> loadWalletBalance() async {
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

    if (wallet.status == 'success') {
      return wallet;
    }
  } catch (e) {}

  return null;
}

Future<bool> loadKycStatus() async {
  try {
    final response = await dio.get(baseUrl + kycVerified + '${myAccount.user!.userId}');

    final List data = response.data as List;

    if (data.isEmpty) return false;

    final kyc = KycResponse.fromJson(data.first);

    return kyc.isApproved;
  } catch (e) {}

  return false;
}
