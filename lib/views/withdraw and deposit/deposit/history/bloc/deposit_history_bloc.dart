import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/deposit/datamodel/deposit_history_model.dart';
import 'package:meta/meta.dart';

part 'deposit_history_event.dart';
part 'deposit_history_state.dart';

class DepositHistoryBloc
    extends Bloc<DepositHistoryEvent, DepositHistoryState> {
  DepositHistoryBloc() : super(DepositHistoryInitial()) {
    on<LoadDepositHistory>(_onLoadDepositHistory);
    on<RefreshDepositHistory>(_onRefreshDepositHistory);
  }

  FutureOr<void> _onLoadDepositHistory(
    LoadDepositHistory event,
    Emitter<DepositHistoryState> emit,
  ) async {
    if (event.showLoading) {
      emit(DepositHistoryLoading());
    }

    try {
      final userId = getIt<MyAccountService>().user?.userId;

      if (userId == null) {
        emit(DepositHistoryError(message: 'User not found'));
        return;
      }

      final url = baseUrl + getDepositList + userId.toString();
      final response = await dio.get(url);

      final historyResponse = DepositHistoryResponse.fromJson(response.data);

      if (historyResponse.deposits.isEmpty) {
        emit(DepositHistoryEmpty());
      } else {
        emit(DepositHistoryLoaded(
          deposits: historyResponse.deposits,
          totalAmount: historyResponse.totalAmount,
        ));
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString() ?? 'Failed to load deposit history'
          : 'Failed to load deposit history';
      emit(DepositHistoryError(message: message));
    } catch (e) {
      emit(DepositHistoryError(message: 'Failed to load deposit history'));
    }
  }

  FutureOr<void> _onRefreshDepositHistory(
    RefreshDepositHistory event,
    Emitter<DepositHistoryState> emit,
  ) async {
    // Don't show loading indicator for refresh
    add(LoadDepositHistory(showLoading: false));
  }
}
