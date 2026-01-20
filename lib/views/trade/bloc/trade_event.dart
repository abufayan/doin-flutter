// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, strict_top_level_inference, must_be_immutable

import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:meta/meta.dart';

@immutable
sealed class TradeEvent {}

final class LoadTrade extends TradeEvent {}

/// Event to refresh only the account balance
final class TradeSellPressed extends TradeEvent {
  Map<String, dynamic> data;
  TradeSellPressed({required this.data});
}

final class TradeBuyPressed extends TradeEvent {
  Map<String, dynamic> data;
  BuildContext conext;
  TradeBuyPressed({required this.data, required this.conext});
}

