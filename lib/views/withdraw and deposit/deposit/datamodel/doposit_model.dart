import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/CommonData/payment_method_model.dart';

class DepositMethodConfig {
  final DepositMethodType type;
  final String title;
  final String currency;
  final String minDepositText;
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

  /// Dynamic data from API (qr_code and address)
  final PaymentMethodItem? apiData;

  const DepositMethodConfig({
    required this.type,
    required this.title,
    required this.currency,
    required this.minDepositText,
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

  /// Create a copy with API data
  DepositMethodConfig copyWithApiData(PaymentMethodItem apiData) {
    return DepositMethodConfig(
      type: type,
      title: title,
      currency: currency,
      minDepositText: minDepositText,
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
  static DepositMethodConfig fromApiData(PaymentMethodItem apiData) {
    final isUpi = apiData.paymentMode.toUpperCase() == 'UPI';
    final type = _getDepositMethodType(apiData.paymentMode);
    final steps = _getEffectiveSteps(type);


    return DepositMethodConfig(
      type: type,
      title: apiData.displayName,
      currency: apiData.currency,
      minDepositText: 'Minimum deposit : ',
      steps: steps,
      iconAsset: apiData.iconAsset,
      processingTime: 'Within 24 hours',
      fees: '0%',
      limit: isUpi ? '₹900 – ₹200,000' : '10 – 200,000 USD',
      note: isUpi
          ? 'After transferring the amount, please enter the UTR ID and upload the payment screenshot (maximum file size: 2MB)'
          : 'After transferring the amount, please enter the TxID and upload the payment screenshot (maximum file size: 2MB)',
      symbol: apiData.symbolAsset,
      qrImage: apiData.qrCode,
      addressValue: apiData.address,
      requireTxnId: true,
      requireScreenshot: true,
      apiData: apiData,
    );
  }

  static DepositMethodType _getDepositMethodType(String paymentMode) {
    switch (paymentMode.toLowerCase()) {
      case 'upi':
        return DepositMethodType.upi;
      case 'usdt':
      case 'usdt_bep20':
        return DepositMethodType.usdtBep20;
      case 'usdt_trc_20':
        return DepositMethodType.usdtTrc20;
      case 'usdt_erc_20':
        return DepositMethodType.usdtErc20;
      case 'bitcoin':
        return DepositMethodType.bitcoin;
      case 'bank_transfer':
        return DepositMethodType.bankTransfer;
      default:
        return DepositMethodType.none;
    }
  }

  static List<String> _getEffectiveSteps(DepositMethodType type) {
    if (type == DepositMethodType.upi) {
      return _upiSteps;
    } else if (type == DepositMethodType.usdtBep20) {
      return _usdtBep20Steps;
    } else if (type == DepositMethodType.usdtTrc20) {
      return _usdtTrc20Steps;
    } else if (type == DepositMethodType.usdtErc20) {
      return _usdtErc20Steps;
    } else if(type == DepositMethodType.bankTransfer) {
      return _bankSteps;
    }
    else {
      return [];
    }
  }

  static const List<String> _usdtBep20Steps = [
    'Enter the amount in USD.',
    'Scan the QR Code or use USDT BEP 20 Address to make your payment.',
    'Enter the Txid.',
    'Upload payment screenshot.',
    "Click 'Submit' and your amount will be reflected in your account shortly.",
  ];

  static const List<String> _usdtTrc20Steps = [
    'Enter the amount in USD.',
    'Scan the QR Code or use USDT TRC 20 Address to make your payment.',
    'Enter the Txid.',
    'Upload payment screenshot.',
    "Click 'Submit' and your amount will be reflected in your account shortly.",
  ];

  static const List<String> _usdtErc20Steps = [
    'Enter the amount in USD.',
    'Scan the QR Code or use USDT ERC 20 Address to make your payment.',
    'Enter the Txid.',
    'Upload payment screenshot.',
    "Click 'Submit' and your amount will be reflected in your account shortly.",
  ];

  static const List<String> _upiSteps = [
    'Enter the amount in INR',
    'Scan the QR Code or Use UPI Id to make your payment.',
    'Enter the UTR / Transaction ID.',
    'Upload payment screenshot.',
    "Click DEPOSIT and your amount reflects in your account",
  ];

  static const List<String> _bankSteps = [
    'Enter the amount in INR.',
    'Verify bank details.',
    'Upload payment screenshot.',
    'Click Withdraw and your fund will get processed.',
  ];
}
