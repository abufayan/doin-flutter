import 'package:doin_fx/core/enums.dart';

String resolveType(WithdrawMethodType type) {
  switch (type) {
    case WithdrawMethodType.usdtBep20:
      return 'USDT (BEP20)';
    case WithdrawMethodType.usdtErc20:
      return 'USDT (ERC20)';
    case WithdrawMethodType.usdtTrc20:
      return 'USDT (TRC20)';
    case WithdrawMethodType.upi:
      return 'UPI';
    case WithdrawMethodType.bankTransfer:
      return 'Bank Transfer';
    case WithdrawMethodType.none:
      return 'None';
  }
}

bool isWithDraw(WithdrawMethodType type) {
  switch (type) {
    case WithdrawMethodType.usdtBep20:
      return true;
    case WithdrawMethodType.usdtErc20:
      return true;
    case WithdrawMethodType.usdtTrc20:
      return true;
    case WithdrawMethodType.upi:
      return true;
    case WithdrawMethodType.bankTransfer:
      return true;
    case WithdrawMethodType.none:
      return true;
  }
}
