final String loginToApp = 'api/auth/login';

final String sendEmailOtp = 'api/auth/send-email-otp'; 

final String verifyEmailOtp = 'api/auth/verify-email-otp'; 

final String register = 'api/auth/register'; 

final String logOut = 'api/auth/logout'; 


// My Account 

// GET
final String getRealWalletBalance = 'api/wallet/';

// GET
final String getDemoWalletBalance = 'api/demoaccount/demo-account/';

// POST 
final String updateDemoWallet = 'api/demoaccount/demo-account'; 

// GET
final String bannerUrl = 'api/banner/view';

// GET
final String kycVerified = 'api/kyc/status/';


// By Default The Registered User Will Be in Real Account 
//And then Using This URl The USer switches back and forth

// PUT 
final String switchAccountType = 'api/demoaccount/demo/account-type/';

// GET 
final String fetchAllPairs = 'api/spread/getspread';

// GET 
final String fetchFavouritePairs = 'api/favourites/user/';

//GET
final String addtoFavourite = 'api/favourites/add';
// body: symbol, user_id
// For eg: USDCAD, 113123


/////////////// BUY ////////////////////

final String placeOrder = 'api/order/place';

////////////


// Open trades:
final String getOpenTrades = 'api/order';
// user_id=113132&status=active


/////////////////
///
// http//:localhost:5000/api/auth/send-email-otp
// body: email, username

// http//:localhost:5000/api/auth/verify-email-otp
// body: email, otp

// http//:localhost:5000/api/auth/verify-forgot-password-otp
// body: email, otp

// http//:localhost:5000/api/auth/forgot-password
// body: email

// http//:localhost:5000/api/auth/change-password
// body: user_id, oldPassword, newPassword, confirmPassword

// http//:localhost:5000/api/auth/reset-password
// body: email, password, confirmPasssword 

// http//:localhost:5000/api/auth/change-password
// body: user_id, oldPassword, newPassword, confirmPassword

// http//:localhost:5000/api/auth/register
// body: username, email, password, confirmPassword, whatsapp_number

// http//:localhost:5000/api/auth/login
// body: email, password