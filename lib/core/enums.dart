enum AppType { Local, Production }

enum AccountType { live, demo }

enum TradeSide { buy, sell }

enum OrderType { market, limit, advanced }

enum DepositMethodType {
  upi,
  usdtBep20,
  usdtTrc20,
  usdtErc20,
  bitcoin,
  bankTransfer,
  none,
}

enum WithdrawMethodType {
  upi,
  usdtBep20,
  usdtTrc20,
  usdtErc20,
  bankTransfer,
  none,
}

enum TicketStatus { open, closed }
