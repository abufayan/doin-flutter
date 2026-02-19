/// Model for deposit history list response
class DepositHistoryResponse {
  final List<DepositHistoryItem> deposits;
  final double totalAmount;

  DepositHistoryResponse({
    required this.deposits,
    required this.totalAmount,
  });

  factory DepositHistoryResponse.fromJson(Map<String, dynamic> json) {
    return DepositHistoryResponse(
      deposits: (json['deposit'] as List<dynamic>?)
              ?.map((e) => DepositHistoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
    );
  }
}

/// Individual deposit item in history
class DepositHistoryItem {
  final int depositId;
  final int userId;
  final String paymentMethod;
  final String transactionId;
  final double transferAmountUsd;
  final double enterAmount;
  final double requestedAmountUsd;
  final String depositStatus;
  final DateTime depositRequestAt;

  DepositHistoryItem({
    required this.depositId,
    required this.userId,
    required this.paymentMethod,
    required this.transactionId,
    required this.transferAmountUsd,
    required this.enterAmount,
    required this.requestedAmountUsd,
    required this.depositStatus,
    required this.depositRequestAt,
  });

  factory DepositHistoryItem.fromJson(Map<String, dynamic> json) {
    return DepositHistoryItem(
      depositId: json['deposit_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      paymentMethod: json['payment_method'] as String? ?? '',
      transactionId: json['transaction_id'] as String? ?? '',
      transferAmountUsd:
          double.tryParse(json['transfer_amount_usd']?.toString() ?? '0') ?? 0.0,
      enterAmount:
          double.tryParse(json['enter_amount']?.toString() ?? '0') ?? 0.0,
      requestedAmountUsd:
          double.tryParse(json['requested_amount_usd']?.toString() ?? '0') ?? 0.0,
      depositStatus: json['deposit_status'] as String? ?? 'pending',
      depositRequestAt: DateTime.tryParse(json['deposit_request_at'] ?? '') ??
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
  bool get isPending => depositStatus.toLowerCase() == 'pending';

  /// Check if status is completed/approved
  bool get isCompleted =>
      depositStatus.toLowerCase() == 'completed' ||
      depositStatus.toLowerCase() == 'approved';

  /// Check if status is rejected
  bool get isRejected => depositStatus.toLowerCase() == 'rejected';
}
