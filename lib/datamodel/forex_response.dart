import 'package:flutter/foundation.dart';

@immutable
class ForexResponse {
  final List<ForexItem> marketQuotes;

  const ForexResponse({
    required this.marketQuotes,
  });

  factory ForexResponse.fromJson(List<dynamic> json) {
    return ForexResponse(
      marketQuotes: json
          .map((e) => ForexItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return marketQuotes.map((e) => e.toJson()).toList();
  }
}


@immutable
class ForexItem {
  final double p;
  final double a;
  final double b;
  final String s;
  final int t;

  const ForexItem({
    required this.p,
    required this.a,
    required this.b,
    required this.s,
    required this.t,
  });

  factory ForexItem.fromJson(Map<String, dynamic> json) {
    return ForexItem(
      p: double.tryParse(json['p']?.toString() ?? '0') ?? 0.0,
      a: double.tryParse(json['a']?.toString() ?? '0') ?? 0.0,
      b: double.tryParse(json['b']?.toString() ?? '0') ?? 0.0,
      s: json['s'] as String? ?? '',
      t: json['t'] as int? ?? 0,
    );
  }

  DateTime get time =>
      DateTime.fromMillisecondsSinceEpoch(t);

  Map<String, dynamic> toJson() {
    return {
      'p': p,
      'a': a,
      'b': b,
      's': s,
      't': t,
    };
  }
}
