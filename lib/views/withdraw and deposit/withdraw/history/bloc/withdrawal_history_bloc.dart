import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/withdraw/datamodel/withdrawal_history_model.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'withdrawal_history_event.dart';
part 'withdrawal_history_state.dart';

class WithdrawalHistoryBloc
    extends Bloc<WithdrawalHistoryEvent, WithdrawalHistoryState> {
  WithdrawalHistoryBloc() : super(WithdrawalHistoryInitial()) {
    on<LoadWithdrawalHistory>(_onLoadWithdrawalHistory);
    on<RefreshWithdrawalHistory>(_onRefreshWithdrawalHistory);
    on<FilterWithdrawalHistory>(_onFilterWithdrawalHistory);
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
          filteredWithdrawals: historyResponse.withdrawals,
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

  FutureOr<void> _onFilterWithdrawalHistory(
      FilterWithdrawalHistory event,
      Emitter<WithdrawalHistoryState> emit,
      ) async  {
    if (state is! WithdrawalHistoryLoaded) return;

    final currentState = state as WithdrawalHistoryLoaded;

    // Always start from original list
    List<WithdrawalHistoryItem> filtered =
    List.from(currentState.withdrawals);

    final query = event.searchQuery.trim().toLowerCase();

    /// 🔎 SEARCH FILTER
    if (query.isNotEmpty) {
      filtered = filtered.where((withdrawal) {
        return withdrawal.withdrawalId.toString().contains(query) ||
            withdrawal.paymentMethodDisplay.toLowerCase().contains(query) ||
            withdrawal.withdrawalStatus.toLowerCase().contains(query) ||
            withdrawal.transferAmountUsd.toString().contains(query) ||
            withdrawal.requestedAmountUsd.toString().contains(query) ||
            withdrawal.paymentAddressUpiId.toLowerCase().contains(query);
      }).toList();
    }

    /// 📅 DATE FILTER
    if (event.dateRange != null) {
      filtered = filtered.where((withdrawal) {
        return withdrawal.withdrawalRequestAt.isAfter(
            event.dateRange!.start.subtract(const Duration(seconds: 1))) &&
            withdrawal.withdrawalRequestAt.isBefore(
                event.dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    emit(WithdrawalHistoryLoaded(
      withdrawals: currentState.withdrawals,
      filteredWithdrawals: filtered,
    ));
  }
}
