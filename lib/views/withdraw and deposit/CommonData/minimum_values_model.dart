class PaymentConfigResponse {
  final bool success;
  final String message;
  final PaymentConfig data;

  PaymentConfigResponse({required this.success, required this.message, required this.data});

  factory PaymentConfigResponse.fromJson(Map<String, dynamic> json) {
    return PaymentConfigResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: PaymentConfig.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class PaymentConfig {
  final double minimumDeposit;
  final double minimumWithdrawal;
  final double inrValue;
  final double depositFee;
  final double withdrawalFee;

  PaymentConfig({
    required this.minimumDeposit,
    required this.minimumWithdrawal,
    required this.inrValue,
    required this.depositFee,
    required this.withdrawalFee,
  });

  factory PaymentConfig.fromJson(Map<String, dynamic> json) {
    double parse(dynamic value) => double.tryParse(value?.toString() ?? '0') ?? 0;

    return PaymentConfig(
      minimumDeposit: parse(json['minimum_deposit']),
      minimumWithdrawal: parse(json['minimum_withdrawal']),
      inrValue: parse(json['inr_value']),
      depositFee: parse(json['deposit_fee']),
      withdrawalFee: parse(json['withdrawal_fee']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minimum_deposit': minimumDeposit,
      'minimum_withdrawal': minimumWithdrawal,
      'inr_value': inrValue,
      'deposit_fee': depositFee,
      'withdrawal_fee': withdrawalFee,
    };
  }

  PaymentConfig copyWith({
    double? minimumDeposit,
    double? minimumWithdrawal,
    double? inrValue,
    double? depositFee,
    double? withdrawalFee,
  }) {
    return PaymentConfig(
      minimumDeposit: minimumDeposit ?? this.minimumDeposit,
      minimumWithdrawal: minimumWithdrawal ?? this.minimumWithdrawal,
      inrValue: inrValue ?? this.inrValue,
      depositFee: depositFee ?? this.depositFee,
      withdrawalFee: withdrawalFee ?? this.withdrawalFee,
    );
  }
}
