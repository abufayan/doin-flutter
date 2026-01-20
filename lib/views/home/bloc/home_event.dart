import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/views/home/bloc/home_state.dart';
import 'package:meta/meta.dart';

@immutable
sealed class HomeEvent {}

final class SelectTab extends HomeEvent {
  final int index;
  SelectTab(this.index);
}

final class SwitchAccount extends HomeEvent {
  final AccountType accountType;
  SwitchAccount({required this.accountType});
}

final class RestoreAccount extends HomeEvent {
  final AccountType accountType;
  RestoreAccount({required this.accountType});
}