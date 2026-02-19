/// Central place for all API path constants.
/// Only the path segment is defined here; `baseUrl` is composed elsewhere.
library;

/* ===================== AUTH ===================== */

final String loginToApp = 'api/auth/login';
final String sendEmailOtp = 'api/auth/send-email-otp';
final String verifyEmailOtp = 'api/auth/verify-email-otp';
final String register = 'api/auth/register';
final String logOut = 'api/auth/logout';

// Profile & password
final String getProfileDetails = 'api/auth/profile/details';
final String updateProfile = 'api/auth/profile/update';
final String changePassword = 'api/auth/change-password';
final String forgotPassword = 'api/auth/forgot-password';
final String verifyForgotPasswordOtp = 'api/auth/verify-forgot-password-otp';
final String resetPassword = 'api/auth/reset-password';

/* ===================== ACCOUNT / WALLET ===================== */

// Real & demo wallet balances
final String getRealWalletBalance = 'api/wallet/'; // + userId
final String getDemoWalletBalance = 'api/demoaccount/demo-account/'; // + userId

// Demo wallet update
final String updateDemoWallet = 'api/demoaccount/demo-account';

// Account type switching (LIVE / DEMO)
// By default a registered user will be in real account,
// and this endpoint is used to switch back and forth.
final String switchAccountType =
    'api/demoaccount/demo/account-type/'; // + userId

// General values / config (min deposit, withdrawal, etc.)
final String getMinimummDepsitValues = 'api/values/getdata';

/* ===================== KYC ===================== */

final String kycVerified = 'api/kyc/status/'; // + userId
final String kycSubmit = 'api/kyc/submit';

/* ===================== MARKET DATA & FAVOURITES ===================== */

// Spreads / symbols
final String fetchAllPairs = 'api/spread/getspread';

// Favourites
final String fetchFavouritePairs = 'api/favourites/user/'; // + userId
final String addtoFavourite = 'api/favourites/add'; // body: symbol, user_id
final String removeFavourite = 'api/favourites/remove';

/* ===================== UI / CONTENT ===================== */

final String bannerUrl = 'api/banner/view';

/* ===================== SUPPORT / TICKETS ===================== */

final String getTickets = 'api/support/support/user/'; // + userId
final String createTicket = 'api/support';
final String getTicketDetailsUrl = 'api/support/'; // + ticketId
final String getContactInfo = 'api/contact';

/* ===================== TRADING / ORDERS ===================== */

// Place order (BUY / SELL)
final String placeOrder = 'api/order/place';

// Open trades:
// Example query: user_id=113132&status=active
final String getTrades = 'api/order';

// Bulk close
final String closeAllPositions = 'api/order/close/all/positions';
final String closeAllProfitPositions = 'api/order/close/all/profit/positions';
final String closeAllLossPositions = 'api/order/close/all/loss/positions';

/* ===================== FUNDS: DEPOSIT / WITHDRAWAL ===================== */

final String depositAmount = 'api/deposit/create';
final String getDepositList = 'api/deposit/list/user/'; // + userId
final String getActivePaymentMethods = 'api/payment/getactive'; // ?type=deposit or ?type=withdrawal
final String withdrawal = 'api/withdrawal';
final String getWithdrawalList = 'api/withdrawal/user/'; // + userId

/* ===================== DEMO ACCOUNT ENDPOINTS ===================== */

// Demo Orders
final String demoPlaceOrder = 'api/demo/order/place'; 
final String demoGetTrades = 'api/demo/order';
final String demoCloseAllPositions = 'api/demo/order/close/all/positions';
final String demoCloseAllProfitPositions =
    'api/demo/order/close/all/profit/positions';
final String demoCloseAllLossPositions =
    'api/demo/order/close/all/loss/positions';

// Demo Favourites
final String fetchDemoFavouritePairs = 'api/demofavourites/user/'; // + userId
final String addtoDemoFavourite =
    'api/demofavourites/add'; // body: user_id, symbol
final String removeDemoFavourite =
    'api/demofavourites/remove'; // body: user_id, symbol
