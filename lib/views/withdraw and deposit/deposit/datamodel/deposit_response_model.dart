import 'package:flutter/foundation.dart';

@immutable
class DepositResponseModel {
  final String status;
  final String message;
  final int? depositId;
  final String? paymentScreenshot;
  final String? error;

  const DepositResponseModel({
    required this.status,
    required this.message,
    this.depositId,
    this.paymentScreenshot,
    this.error,
  });

  factory DepositResponseModel.fromJson(Map<String, dynamic> json) {
    return DepositResponseModel(
      status: json['status'] as String? ?? 'error',
      message: json['message'] as String? ?? 'Unknown error',
      depositId: json['deposit_id'] as int?,
      paymentScreenshot: json['payment_screenshot'] as String?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'deposit_id': depositId,
      'payment_screenshot': paymentScreenshot,
      'error': error,
    };
  }

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';
}
