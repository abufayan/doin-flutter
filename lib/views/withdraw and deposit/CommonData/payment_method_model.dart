/// Model for active payment methods API response
class ActivePaymentMethodsResponse {
  final bool success;
  final List<PaymentMethodItem> data;

  ActivePaymentMethodsResponse({required this.success, required this.data});

  factory ActivePaymentMethodsResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];

    // The API returns nested array [[{...}, {...}]]
    List<PaymentMethodItem> items = [];
    for (var item in dataList) {
      if (item is List) {
        // Handle nested array structure
        for (var innerItem in item) {
          if (innerItem is Map<String, dynamic>) {
            items.add(PaymentMethodItem.fromJson(innerItem));
          }
        }
      } else if (item is Map<String, dynamic>) {
        items.add(PaymentMethodItem.fromJson(item));
      }
    }

    return ActivePaymentMethodsResponse(success: json['success'] as bool? ?? false, data: items);
  }
}

/// Individual payment method item from API
class PaymentMethodItem {
  final int id;
  final String paymentMode;
  final String qrCode;
  final String address;
  final String depositStatus;
  final String withdrawalStatus;
  final String? bankAccountNumber;
  final String? bankIfscCode;
  final String? bankAccountName;
  final String? bankName;
  final String? bankPostalCode;
  final String? bankCity;
  final String? country;
  final String isUsed;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentMethodItem({
    required this.id,
    required this.paymentMode,
    required this.qrCode,
    required this.address,
    required this.depositStatus,
    required this.withdrawalStatus,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.bankAccountName,
    this.bankName,
    this.bankPostalCode,
    this.bankCity,
    this.country,
    required this.isUsed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentMethodItem.fromJson(Map<String, dynamic> json) {
    return PaymentMethodItem(
      id: json['id'] as int? ?? 0,
      paymentMode: json['payment_mode'] as String? ?? '',
      qrCode: json['qr_code'] as String? ?? '',
      address: json['address'] as String? ?? '',
      depositStatus: json['deposit_status'] as String? ?? 'inactive',
      withdrawalStatus: json['withdrawal_status'] as String? ?? 'inactive',
      bankAccountNumber: json['bank_account_number'] as String?,
      bankIfscCode: json['bank_ifsc_code'] as String?,
      bankAccountName: json['bank_account_name'] as String?,
      bankName: json['bank_name'] as String?,
      bankPostalCode: json['bank_postal_code'] as String?,
      bankCity: json['bank_city'] as String?,
      country: json['country'] as String?,
      isUsed: json['is_used'] as String? ?? 'inactive',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  /// Check if deposit is active
  bool get isDepositActive => depositStatus.toLowerCase() == 'active';

  /// Check if withdrawal is active
  bool get isWithdrawalActive => withdrawalStatus.toLowerCase() == 'active';

  /// Get display-friendly payment mode name
  String get displayName {
    // print('paymentMode : ${paymentMode}');
    // print('${paymentMode == 'bitcoin'}');

    switch (paymentMode.toLowerCase()) {
      case 'upi':
        return 'UPI';
      case 'usdt':
        return 'USDT (BEP20)';
      case 'usdt_bep20':
        return 'USDT (BEP20)';
      case 'usdt_trc_20':
        return 'USDT (TRC20)';
      case 'usdt_erc_20':
        return 'USDT (ERC20)';
      case 'bitcoin':
        return 'Bitcoin';
      case 'bank_transfer':
        return 'Bank Transfer';
      default:
        return paymentMode;
    }
  }

  /// Get icon asset path based on payment mode
  String get iconAsset {
    switch (paymentMode.toUpperCase()) {
      case 'UPI':
        return 'assets/images/deposit/upi.png';
      case 'USDT':
      case 'USDT_BEP20':
      case 'USDT_TRC_20':
      case 'USDT_ERC_20':
        return 'assets/images/deposit/usdt.png';
      // case 'bitcoin':
      //   return 'assets/images/deposit/bitcoin.png';
      default:
        return 'assets/images/deposit/usdt.png';
    }
  }

  /// Get currency symbol asset
  String get symbolAsset {
    switch (paymentMode.toUpperCase()) {
      case 'UPI':
        return 'assets/images/deposit/rupee_symbol.png';
      default:
        return 'assets/images/deposit/usd_symbol.png';
    }
  }

  /// Get currency code
  String get currency {
    switch (paymentMode.toUpperCase()) {
      case 'UPI':
      case 'BANK_TRANSFER':
        return 'INR';
      default:
        return 'USD';
    }
  }

  /// Check if this is a bank transfer method
  bool get isBankTransfer => paymentMode.toUpperCase() == 'BANK_TRANSFER';

  /// Get formatted bank details for display
  String get bankDetailsDisplay {
    if (!isBankTransfer) return '';

    final parts = <String>[];
    if (bankName != null && bankName!.isNotEmpty) parts.add('Bank: $bankName');
    if (bankAccountName != null && bankAccountName!.isNotEmpty) parts.add('A/C Name: $bankAccountName');
    if (bankAccountNumber != null && bankAccountNumber!.isNotEmpty) parts.add('A/C No: $bankAccountNumber');
    if (bankIfscCode != null && bankIfscCode!.isNotEmpty) parts.add('IFSC: $bankIfscCode');
    if (bankCity != null && bankCity!.isNotEmpty) parts.add('City: $bankCity');

    return parts.join('\n');
  }
}
