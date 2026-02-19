import 'package:flutter/foundation.dart';

@immutable
class BannerResponse {

  final bool success;
  final List<BannerItem> banners;

  const BannerResponse({
    required this.success,
    required this.banners,
  });

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    return BannerResponse(
      success: json['success'] as bool? ?? false,
      banners: (json['banners'] as List<dynamic>? ?? [])
          .map((e) => BannerItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'banners': banners.map((e) => e.toJson()).toList(),
    };
  }
}



class BannerItem {
  final int id;
  final String image;
  final String status;
  final DateTime createdAt;

  const BannerItem({
    required this.id,
    required this.image,
    required this.status,
    required this.createdAt,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'] as int? ?? 0,
      image: json['image'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}




@immutable
class WalletResponse {
  final String status;
  final double wallet;
  final double used_margin;
  final double after_used_margin;
  final String username;
  final String email;

  const WalletResponse({
    required this.status,
    required this.wallet,
    required this.used_margin,
    required this.after_used_margin,
    required this.username,
    required this.email,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      status: json['status'] as String? ?? '',
      wallet: double.tryParse(json['wallet']?.toString() ?? '0') ?? 0.0,
      used_margin:
          double.tryParse(json['used_margin']?.toString() ?? '0') ?? 0.0,
      after_used_margin:
          double.tryParse(json['after_used_margin']?.toString() ?? '0') ?? 0.0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'wallet': wallet.toStringAsFixed(2),
      'used_margin': used_margin.toStringAsFixed(2),
      'after_used_margin': after_used_margin.toStringAsFixed(2),
      'username': username,
      'email': email,
    };
  }

  bool get is_success => status.toLowerCase() == 'success';
}



