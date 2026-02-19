/// Model for withdrawal history list response
class WithdrawalHistoryResponse {
  final List<WithdrawalHistoryItem> withdrawals;

  WithdrawalHistoryResponse({
    required this.withdrawals,
  });

  factory WithdrawalHistoryResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawalHistoryResponse(
      withdrawals: (json['withdraw'] as List<dynamic>?)
              ?.map((e) => WithdrawalHistoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Individual withdrawal item in history
class WithdrawalHistoryItem {
  final int withdrawalId;
  final int userId;
  final String paymentMethod;
  final String withdrawalStatus;
  final double requestedAmountUsd;
  final double transferAmountUsd;
  final String paymentAddressUpiId;
  final DateTime withdrawalRequestAt;

  WithdrawalHistoryItem({
    required this.withdrawalId,
    required this.userId,
    required this.paymentMethod,
    required this.withdrawalStatus,
    required this.requestedAmountUsd,
    required this.transferAmountUsd,
    required this.paymentAddressUpiId,
    required this.withdrawalRequestAt,
  });

  factory WithdrawalHistoryItem.fromJson(Map<String, dynamic> json) {
    return WithdrawalHistoryItem(
      withdrawalId: json['withdrawal_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      paymentMethod: json['payment_method'] as String? ?? '',
      withdrawalStatus: json['withdrawal_status'] as String? ?? 'pending',
      requestedAmountUsd:
          double.tryParse(json['requested_amount_usd']?.toString() ?? '0') ?? 0.0,
      transferAmountUsd:
          double.tryParse(json['transfer_amount_usd']?.toString() ?? '0') ?? 0.0,
      paymentAddressUpiId: json['payment_address_upi_id'] as String? ?? '',
      withdrawalRequestAt: DateTime.tryParse(json['withdrawal_request_at'] ?? '') ??
          DateTime.now(),
    );
  }

  /// Get display-friendly payment method name
  String get paymentMethodDisplay {
    switch (paymentMethod.toLowerCase()) {
      case 'upi':
        return 'UPI';
      case 'usdt':
      case 'usdt_bep20':
      case 'usdt_trc20':
      case 'usdt_erc20':
        return 'USDT';
      case 'bank':
        return 'Bank';
      default:
        return paymentMethod.toUpperCase();
    }
  }

  /// Check if status is pending
  bool get isPending => withdrawalStatus.toLowerCase() == 'pending';

  /// Check if status is completed/approved
  bool get isCompleted =>
      withdrawalStatus.toLowerCase() == 'completed' ||
      withdrawalStatus.toLowerCase() == 'approved';

  /// Check if status is rejected
  bool get isRejected => withdrawalStatus.toLowerCase() == 'rejected';
}
