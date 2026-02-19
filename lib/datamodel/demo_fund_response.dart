import 'package:flutter/foundation.dart';

/// Response model for the demo account add-fund API.
///
/// Success: `{ "status": "success", "message": "...", "data": { "user_id": "53", "balance": 1200.498219 } }`
/// Error:   `{ "status": "error", "message": "MISSING_FIELDS" }`
@immutable
class DemoFundResponse {
  final String status;
  final String message;
  final DemoFundData? data;

  const DemoFundResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory DemoFundResponse.fromJson(Map<String, dynamic> json) {
    return DemoFundResponse(
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? DemoFundData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isSuccess => status.toLowerCase() == 'success';

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (data != null) 'data': data!.toJson(),
    };
  }
}

@immutable
class DemoFundData {
  final String userId;
  final double balance;

  const DemoFundData({required this.userId, required this.balance});

  factory DemoFundData.fromJson(Map<String, dynamic> json) {
    return DemoFundData(
      userId: json['user_id']?.toString() ?? '',
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'balance': balance};
  }
}
