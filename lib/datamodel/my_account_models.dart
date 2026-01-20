class PaymentMethod {
  final String id;
  final String paymentMode;
  final String displayName;
  final bool isActive;

  PaymentMethod({
    required this.id,
    required this.paymentMode,
    required this.displayName,
    required this.isActive,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id']?.toString() ?? '',
      paymentMode: json['payment_mode']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? json['payment_mode']?.toString() ?? '',
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_mode': paymentMode,
      'display_name': displayName,
      'is_active': isActive,
    };
  }
}

class WalletData {
  final int userId;
  final double balance;
  final String currency;
  final String accountType; // 'real' or 'demo'

  WalletData({
    required this.userId,
    required this.balance,
    required this.currency,
    required this.accountType,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      userId: json['user_id'] ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      accountType: json['account_type']?.toString() ?? 'real',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'balance': balance,
      'currency': currency,
      'account_type': accountType,
    };
  }
}

class KycStatus {
  final int userId;
  final String status; // 'pending', 'verified', 'rejected'
  final String? reason;
  final DateTime? verifiedDate;

  KycStatus({
    required this.userId,
    required this.status,
    this.reason,
    this.verifiedDate,
  });

  factory KycStatus.fromJson(Map<String, dynamic> json) {
    return KycStatus(
      userId: json['user_id'] ?? 0,
      status: json['status']?.toString() ?? 'pending',
      reason: json['reason']?.toString(),
      verifiedDate: json['verified_date'] != null ? DateTime.parse(json['verified_date'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'status': status,
      'reason': reason,
      'verified_date': verifiedDate?.toIso8601String(),
    };
  }
}

class DemoAccountData {
  final int userId;
  final double initialBalance;
  final String accountType;
  final DateTime createdDate;

  DemoAccountData({
    required this.userId,
    required this.initialBalance,
    required this.accountType,
    required this.createdDate,
  });

  factory DemoAccountData.fromJson(Map<String, dynamic> json) {
    return DemoAccountData(
      userId: json['user_id'] ?? 0,
      initialBalance: (json['initial_balance'] as num?)?.toDouble() ?? 0.0,
      accountType: json['account_type']?.toString() ?? 'demo',
      createdDate: json['created_date'] != null ? DateTime.parse(json['created_date'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'initial_balance': initialBalance,
      'account_type': accountType,
      'created_date': createdDate.toIso8601String(),
    };
  }
}

class DepositResponse {
  final bool success;
  final String message;
  final String? transactionId;
  final String? status;

  DepositResponse({
    required this.success,
    required this.message,
    this.transactionId,
    this.status,
  });

  factory DepositResponse.fromJson(Map<String, dynamic> json) {
    return DepositResponse(
      success: json['status']?.toString() == 'success',
      message: json['message']?.toString() ?? 'Unknown response',
      transactionId: json['transaction_id']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'transaction_id': transactionId,
      'status': status,
    };
  }
}
