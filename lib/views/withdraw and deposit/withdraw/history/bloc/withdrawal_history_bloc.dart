import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/withdraw/datamodel/withdrawal_history_model.dart';
import 'package:meta/meta.dart';

part 'withdrawal_history_event.dart';
part 'withdrawal_history_state.dart';

class WithdrawalHistoryBloc
    extends Bloc<WithdrawalHistoryEvent, WithdrawalHistoryState> {
  WithdrawalHistoryBloc() : super(WithdrawalHistoryInitial()) {
    on<LoadWithdrawalHistory>(_onLoadWithdrawalHistory);
    on<RefreshWithdrawalHistory>(_onRefreshWithdrawalHistory);
  }

  FutureOr<void> _onLoadWithdrawalHistory(
    LoadWithdrawalHistory event,
    Emitter<WithdrawalHistoryState> emit,
  ) async {
    if (event.showLoading) {
      emit(WithdrawalHistoryLoading());
    }

    try {
      final userId = getIt<MyAccountService>().user?.userId;

      if (userId == null) {
        emit(WithdrawalHistoryError(message: 'User not found'));
        return;
      }

      final url = baseUrl + getWithdrawalList + userId.toString();
      final response = await dio.get(url);

      final historyResponse = WithdrawalHistoryResponse.fromJson(response.data);

      if (historyResponse.withdrawals.isEmpty) {
        emit(WithdrawalHistoryEmpty());
      } else {
        emit(WithdrawalHistoryLoaded(
          withdrawals: historyResponse.withdrawals,
        ));
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString() ?? 'Failed to load withdrawal history'
          : 'Failed to load withdrawal history';
      emit(WithdrawalHistoryError(message: message));
    } catch (e) {
      emit(WithdrawalHistoryError(message: 'Failed to load withdrawal history'));
    }
  }

  FutureOr<void> _onRefreshWithdrawalHistory(
    RefreshWithdrawalHistory event,
    Emitter<WithdrawalHistoryState> emit,
  ) async {
    // Don't show loading indicator for refresh
    add(LoadWithdrawalHistory(showLoading: false));
  }
}
