// ignore_for_file: unnecessary_string_interpolations, prefer_interpolation_to_compose_strings, empty_catches

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/services/token_storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/setup.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    on<SelectTab>((event, emit) {
      emit(HomeTabChanged(
        event.index,
        accountType: state.accountType,
      ));
    });

    on<SwitchAccount>(switchAccount);
    on<RestoreAccount>((event, emit) {
      emit(HomeTabChanged(state.index, accountType: event.accountType));
    });

    // Restore persisted account type from secure storage (if available)
    Future.microtask(() async {
      final user = await TokenStorageService.getUser();
      if (user != null) {
        final acctStr = (user.accountType ?? 'LIVE').toUpperCase();
        final acct = acctStr == 'DEMO' ? AccountType.demo : AccountType.live;
        add(RestoreAccount(accountType: acct)); 
      }
    });
  }

  FutureOr<void> switchAccount(SwitchAccount event, Emitter<HomeState> emit) async {
    try {
      // Show loading state
      emit(AccountSwitched(
        state.index,
        accountType: event.accountType,
        isLoading: true,
      ));

      // Get user ID and token
      final user = await TokenStorageService.getUser();
      final token = await TokenStorageService.getToken();

      if (user?.userId == null || token == null) {
        emit(AccountSwitched(
          state.index,
          accountType: state.accountType,
          isLoading: false,
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      final userId = user!.userId;
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Call appropriate API based on account type
      late http.Response response;
      late String requestUrl;

      if (true) {
        requestUrl = baseUrl + '$switchAccountType' + userId.toString();
        final url = Uri.parse(requestUrl);
        response = await http.put
        (
          url, 
          headers: headers, 
          body: jsonEncode({
            'account_type': event.accountType == AccountType.demo
                ? 'DEMO'
                : 'LIVE',
          }),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) { 
        // Success
        emit(AccountSwitched(
          state.index,
          accountType: event.accountType,
          isLoading: false,
        ));
        // Persist new account type locally so it survives app restarts
        try {
          final currentUser = await TokenStorageService.getUser();
          if (currentUser != null) {
            final updated = currentUser.copyWith(
              accountType: event.accountType == AccountType.demo ? 'DEMO' : 'LIVE',
            );
            await TokenStorageService.saveUser(updated);
            print('Account type updated to: ${updated.accountType}');
          }
        } catch (e) { }
      } else {
        emit(AccountSwitched(
          state.index,
          accountType: state.accountType,
          isLoading: false,
          errorMessage: 'Failed to switch account: ${response.statusCode}',
        ));
      }
    } catch (e) {
      emit(AccountSwitched(
        state.index,
        accountType: state.accountType,
        isLoading: false,
        errorMessage: 'Error switching account: $e',
      ));
    }
  }
}
