import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/CommonData/payment_method_model.dart';

class WithdrawMethodConfig {
  final WithdrawMethodType type;
  final String title;
  final String currency;
  final String minWithdrawText;
  final String iconAsset;
  final String processingTime;
  final String fees;
  final String limit;
  final List<String> steps;
  final String note;

  final String? qrImage;
  final String? addressLabel;
  final String? addressValue;
  final bool requireTxnId;
  final bool requireScreenshot;
  final String symbol;

  /// Dynamic data from API (qr_code, address, bank details)
  final PaymentMethodItem? apiData;

  const WithdrawMethodConfig({
    required this.type,
    required this.title,
    required this.currency,
    required this.minWithdrawText,
    required this.steps,
    required this.iconAsset,
    required this.processingTime,
    required this.fees,
    required this.limit,
    required this.note,
    required this.symbol,
    this.qrImage,
    this.addressLabel,
    this.addressValue,
    this.requireTxnId = false,
    this.requireScreenshot = false,
    this.apiData,
  });

  /// Get the effective QR image - prefer API data over hardcoded
  String? get effectiveQrImage => apiData?.qrCode ?? qrImage;

  /// Get the effective address - prefer API data over hardcoded
  String? get effectiveAddress => apiData?.address ?? addressValue;

  /// Check if this is a bank transfer
  bool get isBankTransfer => apiData?.isBankTransfer ?? false;

  /// Get bank details for display
  String get bankDetails => apiData?.bankDetailsDisplay ?? '';

  /// Create a copy with API data
  WithdrawMethodConfig copyWithApiData(PaymentMethodItem apiData) {
    return WithdrawMethodConfig(
      type: type,
      title: title,
      currency: currency,
      minWithdrawText: minWithdrawText,
      steps: steps,
      iconAsset: iconAsset,
      processingTime: processingTime,
      fees: fees,
      limit: limit,
      note: note,
      symbol: symbol,
      qrImage: qrImage,
      addressLabel: addressLabel,
      addressValue: addressValue,
      requireTxnId: requireTxnId,
      requireScreenshot: requireScreenshot,
      apiData: apiData,
    );
  }

  /// Create config from API PaymentMethodItem
  static WithdrawMethodConfig fromApiData(PaymentMethodItem apiData) {
    final isUpi = apiData.paymentMode.toUpperCase() == 'UPI';
    final isBankTransfer = apiData.paymentMode.toUpperCase() == 'BANK_TRANSFER';
    final type = _getWithdrawMethodType(apiData.paymentMode);

    return WithdrawMethodConfig(
      type: type,
      title: apiData.displayName,
      currency: apiData.currency,
      minWithdrawText: 'Minimum Withdrawl: ',
      steps: isBankTransfer ? _bankSteps : (isUpi ? _upiSteps : _usdtSteps),
      iconAsset: apiData.iconAsset,
      processingTime: 'Within 24 hours',
      fees: '0%',
      limit: isUpi ? '₹900 – ₹200,000' : '10 – 200,000 USD',
      note: isBankTransfer
          ? 'After transferring, please enter the transaction ID and upload the payment screenshot (maximum file size: 2MB)'
          : (isUpi
                ? 'After transferring the amount, please enter the UTR ID and upload the payment screenshot (maximum file size: 2MB)'
                : 'After transferring the amount, please enter the TxID and upload the payment screenshot (maximum file size: 2MB)'),
      symbol: apiData.symbolAsset,
      qrImage: apiData.qrCode,
      addressValue: isBankTransfer ? null : apiData.address,
      requireTxnId: true,
      requireScreenshot: true,
      apiData: apiData,
    );
  }

  static WithdrawMethodType _getWithdrawMethodType(String paymentMode) {
    switch (paymentMode.toUpperCase()) {
      case 'UPI':
        return WithdrawMethodType.upi;
      case 'USDT':
      case 'USDT_BEP20':
        return WithdrawMethodType.usdtBep20;
      case 'USDT_TRC20':
        return WithdrawMethodType.usdtTrc20;
      case 'USDT_ERC20':
        return WithdrawMethodType.usdtErc20;
      case 'BANK_TRANSFER':
        return WithdrawMethodType.bankTransfer;
      default:
        return WithdrawMethodType.none;
    }
  }

  static const List<String> _usdtSteps = [
    'Enter the amount in USD.',
    'Enter your USDT Address.',
    'Upload your QR Code Screenshot.',
    'Click Withdraw and your fund will get processed.',
  ];

  static const List<String> _upiSteps = [
    'Enter the amount in USD.',
    'Enter Your UPI ID.',
    'Upload your QR Code Screenshot.',
    'Click Withdraw and your fund will get processed.',
  ];

  static const List<String> _bankSteps = [
    'Enter the amount in INR.',
    'Verify bank details.',
    'Upload payment screenshot.',
    'Click Withdraw and your fund will get processed.',
  ];
}
