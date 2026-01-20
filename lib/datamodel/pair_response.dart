import 'dart:convert';
import 'package:flutter/foundation.dart';

@immutable
class PairResponse {
  final String message;
  final List<PairItem> pairs;

  const PairResponse({
    required this.message,
    required this.pairs,
  });

  factory PairResponse.fromJson(Map<String, dynamic> json) {
    // The response structure: { "message": "...", "data": [[pairs array], [metadata]] }
    final data = json['data'] as List<dynamic>?;
    final pairsList = data != null && data.isNotEmpty 
        ? (data[0] as List<dynamic>? ?? [])
        : [];

    return PairResponse(
      message: json['message'] as String? ?? '',
      pairs: pairsList
          .map((e) => PairItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': [pairs.map((e) => e.toJson()).toList()],
    };
  }
}

@immutable
class PairItem {
  final int id;
  final String symbol;
  final String spread;
  final List<String> categories; // Parsed from JSON string array
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PairItem({
    required this.id,
    required this.symbol,
    required this.spread,
    required this.categories,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PairItem.fromJson(Map<String, dynamic> json) {
    // Parse category from JSON string like "[\"All\"]" or "[\"Metals\",\"Majors\"]"
    List<String> categories = [];
    try {
      final categoryStr = json['category'] as String? ?? '[]';
      final decoded = jsonDecode(categoryStr) as List<dynamic>?;
      categories = decoded?.map((e) => e.toString()).toList() ?? [];
    } catch (e) {
      // If parsing fails, try to extract categories manually
      categories = [];
    }

    return PairItem(
      id: json['id'] as int? ?? 0,
      symbol: json['symbol'] as String? ?? '',
      spread: json['spread'] as String? ?? '0.00',
      categories: categories,
      status: json['status'] as String? ?? 'inactive',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'spread': spread,
      'category': jsonEncode(categories),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isActive => status.toLowerCase() == 'active';
}

class FavouritesResponse {
  final bool success;
  final String? message;
  final List<FavouriteItem> favourites;

  FavouritesResponse({
    required this.success,
    this.message,
    required this.favourites,
  });

  factory FavouritesResponse.fromJson(Map<String, dynamic> json) {
    return FavouritesResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      favourites: (json['favorites'] as List<dynamic>? ?? [])
          .map((e) => FavouriteItem.fromJson(e))
          .toList(),
    );
  }
}


class FavouriteItem {
  final int id;
  final int userId;
  final String symbol;
  final DateTime createdAt;

  // 🔥 NEW FIELDS
  final double cmp;
  final double low;
  final double high;

  FavouriteItem({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.createdAt,
    required this.cmp,
    required this.low,
    required this.high,
  });

  factory FavouriteItem.fromJson(Map<String, dynamic> json) {
    return FavouriteItem(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      symbol: json['symbol'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),

      // ✅ default values so API doesn’t break
      cmp: (json['cmp'] as num?)?.toDouble() ?? 0.0,
      low: (json['l'] as num?)?.toDouble() ?? 0.0,
      high: (json['h'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// 🔁 Needed for socket updates
  FavouriteItem copyWith({
    double? cmp,
    double? low,
    double? high,
  }) {
    return FavouriteItem(
      id: id,
      userId: userId,
      symbol: symbol,
      createdAt: createdAt,
      cmp: cmp ?? this.cmp,
      low: low ?? this.low,
      high: high ?? this.high,
    );
  }
}


class FavoritesResponse {
  final bool success;
  final String message;

  FavoritesResponse({
    required this.success,
    required this.message,
  });

  // Factory constructor to create from JSON
  factory FavoritesResponse.fromJson(Map<String, dynamic> json) {
    return FavoritesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}
