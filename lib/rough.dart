

    // print('whaNum : ${event.whatsappNumber}');

    // print('we do this incase of the monthly emi\'s');
    // print('Password: ${state.registerData.password}');
    // print('Confirm Password: ${state.registerData.confirmPassword}');
    // print('Username: ${state.registerData.username}');
    // print('Email: ${state.registerData.email}');
    // print('Whatsapp Number: ${event.whatsappNumber}');
    // // print(
    // //   '${state.registerData.password} - ${state.registerData.confirmPassword} ${state.registerData.username} ${state.registerData.email}',
    // // );


// Success log
//     I/flutter ( 3543): numberoutSideEvent 8883493419
// I/flutter ( 3543): {status: success, message: Registration successful. Please log in to continue.}
// E/flutter ( 3543): [ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: Looking up a deactivated widget's ancestor is unsafe.


// how to implement post 
// // Example: Placing a buy trade
// import 'package:doin_fx/setup.dart'; // Import dio instance
// import 'package:dio/dio.dart';

// Future<void> placeBuyTrade({
//   required String symbol,
//   required double quantity,
//   required double price,
// }) async {
//   try {
//     final response = await dio.post(
//       'api/trades/buy', // Your API endpoint
//       data: {
//         'symbol': symbol,
//         'quantity': quantity,
//         'price': price,
//         'type': 'buy',
//       },
//     );

//     // Response handling
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final data = response.data as Map<String, dynamic>;
      
//       if (data['status'] == 'success') {
//         print('Trade placed successfully: ${data['message']}');
//         // Handle success - maybe update UI, show snackbar, etc.
//         return data['trade_id']; // or whatever your API returns
//       } else {
//         throw Exception(data['message'] ?? 'Trade failed');
//       }
//     }
//   } on DioException catch (e) {
//     // Handle Dio errors (401, 403, 500, etc.)
//     if (e.response != null) {
//       // Server responded with error
//       final errorData = e.response?.data as Map<String, dynamic>?;
//       throw Exception(errorData?['message'] ?? 'Trade request failed');
//     } else {
//       // Network error or no response
//       throw Exception('Network error: ${e.message}');
//     }
//   } catch (e) {
//     throw Exception('Unexpected error: $e');
//   }
// }

//Get method as suggested by curson

// Example: Fetching user's trade history
// import 'package:doin_fx/setup.dart';
// import 'package:dio/dio.dart';

// Future<List<Map<String, dynamic>>> getUserTrades() async {
//   try {
//     final response = await dio.get(
//       'api/trades/history',
//       queryParameters: {
//         'page': 1,
//         'limit': 20,
//         // Add any filters you need
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = response.data as Map<String, dynamic>;
      
//       if (data['status'] == 'success') {
//         final trades = data['trades'] as List<dynamic>;
//         return trades.cast<Map<String, dynamic>>();
//       } else {
//         throw Exception(data['message'] ?? 'Failed to fetch trades');
//       }
//     }
    
//     throw Exception('Unexpected response');
//   } on DioException catch (e) {
//     if (e.response != null) {
//       final errorData = e.response?.data as Map<String, dynamic>?;
//       throw Exception(errorData?['message'] ?? 'Request failed');
//     } else {
//       throw Exception('Network error: ${e.message}');
//     }
//   }
// }


// Implementing Trades inside a bloc

// In your TradeBloc or DashboardBloc
// import 'package:doin_fx/setup.dart';
// import 'package:dio/dio.dart';

// // Event
// final class PlaceBuyTradeRequested extends TradeEvent {
//   final String symbol;
//   final double quantity;
//   final double price;
  
//   PlaceBuyTradeRequested({
//     required this.symbol,
//     required this.quantity,
//     required this.price,
//   });
// }

// Handler in BLoC
// FutureOr<void> _onPlaceBuyTrade(
//   PlaceBuyTradeRequested event,
//   Emitter<TradeState> emit,
// ) async {
//   emit(TradeLoading());
  
//   try {
//     final response = await dio.post(
//       'api/trades/buy',
//       data: {
//         'symbol': event.symbol,
//         'quantity': event.quantity,
//         'price': event.price,
//         'type': 'buy',
//       },
//     );

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final data = response.data as Map<String, dynamic>;
      
//       if (data['status'] == 'success') {
//         emit(TradeSuccess(data['message']));
//         // Optionally emit trade data
//       } else {
//         emit(TradeFailure(
//           error: data['error'] ?? 'Error',
//           message: data['message'] ?? 'Trade failed',
//         ));
//       }
//     }
//   } on DioException catch (e) {
//     if (e.response?.statusCode == 401) {
//       // Token expired - interceptor already handles this
//       emit(TradeFailure(error: 'Unauthorized', message: 'Please login again'));
//     } else {
//       final errorData = e.response?.data as Map<String, dynamic>?;
//       emit(TradeFailure(
//         error: 'Trade Error',
//         message: errorData?['message'] ?? e.message ?? 'Trade request failed',
//       ));
//     }
//   } catch (e) {
//     emit(TradeFailure(
//       error: 'Error',
//       message: 'An unexpected error occurred: ${e.toString()}',
//     ));
//   }
// }


//reference
// ✅ POST with data
// await dio.post('api/endpoint', data: {'key': 'value'});

// // ✅ GET with query parameters
// await dio.get('api/endpoint', queryParameters: {'page': 1, 'limit': 10});

// // ✅ PUT request
// await dio.put('api/endpoint/123', data: {'key': 'updated_value'});

// // ✅ DELETE request
// await dio.delete('api/endpoint/123');

// // ✅ With custom headers (if needed)
// await dio.post(
//   'api/endpoint',
//   data: {'key': 'value'},
//   options: Options(
//     headers: {'Custom-Header': 'value'},
//   ),
// );





// import 'dart:convert';
// import 'package:doin_fx/core/apis.dart';
// import 'package:doin_fx/core/services/token_storage_service.dart';
// import 'package:doin_fx/datamodel/myaccount_models.dart';
// import 'package:doin_fx/setup.dart';
// import 'package:http/http.dart' as http;

// class MyAccountApiService {
//   /// Fetch all active payment methods for a specific type (deposit/withdrawal)
//   /// GET /api/payment/getactive?type=deposit
//   static Future<List<PaymentMethod>> getActivePaymentMethods({
//     required String type, // 'deposit' or 'withdrawal'
//   }) async {
//     try {
//       final token = await TokenStorageService.getToken();
//       if (token == null) throw Exception('No authentication token found');

//       final url = Uri.parse('$baseUrl/payment/getactive').replace(
//         queryParameters: {'type': type},
//       );

//       final response = await http.get(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('GET $url → ${response.statusCode}');
//       print('Response: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body) as Map<String, dynamic>;
//         if (data['status'] == 'success') {
//           final List<dynamic> methods = data['data'] ?? [];
//           return methods
//               .map((m) => PaymentMethod.fromJson(m as Map<String, dynamic>))
//               .toList();
//         }
//         throw Exception(data['message'] ?? 'Failed to fetch payment methods');
//       } else {
//         throw Exception('HTTP ${response.statusCode}: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching active payment methods: $e');
//       rethrow;
//     }
//   }

//   /// Fetch payment method details by payment mode
//   /// GET /api/payment/get?payment_mode=usdt
//   static Future<PaymentMethod> getPaymentMethodByMode({
//     required String paymentMode, // 'usdt', 'upi', etc.
//   }) async {
//     try {
//       final token = await TokenStorageService.getToken();
//       if (token == null) throw Exception('No authentication token found');

//       final url = Uri.parse('$baseUrl/payment/get').replace(
//         queryParameters: {'payment_mode': paymentMode},
//       );

//       final response = await http.get(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('GET $url → ${response.statusCode}');
//       print('Response: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body) as Map<String, dynamic>;
//         if (data['status'] == 'success') {
//           return PaymentMethod.fromJson(data['data'] as Map<String, dynamic>);
//         }
//         throw Exception(data['message'] ?? 'Failed to fetch payment method');
//       } else {
//         throw Exception('HTTP ${response.statusCode}: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching payment method: $e');
//       rethrow;
//     }
//   }

//   /// Fetch wallet balance for a user
//   /// GET /api/wallet/{user_id}
//   static Future<WalletData> getWalletBalance({required int userId}) async {
//     try {
//       final token = await TokenStorageService.getToken();
//       if (token == null) throw Exception('No authentication token found');

//       final url = Uri.parse('$baseUrl/wallet/$userId');

//       final response = await http.get(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('GET $url → ${response.statusCode}');
//       print('Response: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body) as Map<String, dynamic>;
//         if (data['status'] == 'success') {
//           return WalletData.fromJson(data['data'] as Map<String, dynamic>);
//         }
//         throw Exception(data['message'] ?? 'Failed to fetch wallet data');
//       } else {
//         throw Exception('HTTP ${response.statusCode}: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching wallet balance: $e');
//       rethrow;
//     }
//   }

//   /// Fetch KYC verification status
//   /// GET /api/kyc/status/{id}
//   static Future<KycStatus> getKycStatus({required int userId}) async {
//     try {
//       final token = await TokenStorageService.getToken();
//       if (token == null) throw Exception('No authentication token found');

//       final url = Uri.parse('$baseUrl/kyc/status/$userId');

//       final response = await http.get(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('GET $url → ${response.statusCode}');
//       print('Response: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body) as Map<String, dynamic>;
//         if (data['status'] == 'success') {
//           return KycStatus.fromJson(data['data'] as Map<String, dynamic>);
//         }
//         throw Exception(data['message'] ?? 'Failed to fetch KYC status');
//       } else {
//         throw Exception('HTTP ${response.statusCode}: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching KYC status: $e');
//       rethrow;
//     }
//   }

//   /// Create a deposit request
//   /// POST /api/deposit/create
//   static Future<DepositResponse> createDeposit({
//     required int userId,
//     required String username,
//     required String email,
//     required String paymentMethod, // 'usdt', 'upi', 'bank', etc.
//     required String transactionId,
//     required double amount,
//     String? upiId,
//     String? usdtAddress,
//     String? bankAccountNumber,
//     String? bankHolderName,
//     String? bankName,
//   }) async {
//     try {
//       final token = await TokenStorageService.getToken();
//       if (token == null) throw Exception('No authentication token found');

//       final url = Uri.parse('$baseUrl/deposit/create');
//       final body = {
//         'user_id': userId,
//         'username': username,
//         'email': email,
//         'payment_method': paymentMethod,
//         'transaction_id': transactionId,
//         'enter_amount': amount,
//         if (upiId != null) 'upi_id': upiId,
//         if (usdtAddress != null) 'usdt_address': usdtAddress,
//         if (bankAccountNumber != null) 'bank_account_number': bankAccountNumber,
//         if (bankHolderName != null) 'bank_holder_name': bankHolderName,
//         if (bankName != null) 'bank_name': bankName,
//       };

//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode(body),
//       );

//       print('POST $url → ${response.statusCode}');
//       print('Request: ${jsonEncode(body)}');
//       print('Response: ${response.body}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body) as Map<String, dynamic>;
//         return DepositResponse.fromJson(data);
//       } else {
//         throw Exception('HTTP ${response.statusCode}: ${response.body}');
//       }
//     } catch (e) {
//       print('Error creating deposit: $e');
//       rethrow;
//     }
//   }

//   /// Switch account type: Real to Demo
//   /// GET /api/demoaccount/demo-account/{user_id}
//   /// The backend toggles/returns demo account data when this endpoint is called.
//   static Future<DemoAccountData> switchToDemoAccount({
//     required int userId,
//   }) async {
//     try {
//       final token = await TokenStorageService.getToken();
//       if (token == null) throw Exception('No authentication token found');

//       final url = Uri.parse('$baseUrl/demoaccount/demo-account/$userId');

//       final response = await http.get(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('GET $url → ${response.statusCode}');
//       print('Response: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body) as Map<String, dynamic>;
//         if (data['status'] == 'success') {
//           return DemoAccountData.fromJson(data['data'] as Map<String, dynamic>);
//         }
//         throw Exception(data['message'] ?? 'Failed to switch to demo account');
//       } else {
//         throw Exception('HTTP ${response.statusCode}: ${response.body}');
//       }
//     } catch (e) {
//       print('Error switching to demo account: $e');
//       rethrow;
//     }
//   }

//   /// Get demo account details
//   /// GET /api/demoaccount/demo-account/{user_id}
//   static Future<DemoAccountData> getDemoAccountData({
//     required int userId,
//   }) async {
//     try {
//       final token = await TokenStorageService.getToken();
//       if (token == null) throw Exception('No authentication token found');

//       // final String url = baseUrl + getDemoWalletBalance + userId.toString();
//       final url = Uri.parse( baseUrl + getDemoWalletBalance + userId.toString() );

//       final response = await http.get(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('GET $url → ${response.statusCode}');
//       print('Response: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body) as Map<String, dynamic>;
//         if (data['status'] == 'success') {
//           return DemoAccountData.fromJson(data['data'] as Map<String, dynamic>);
//         }
//         throw Exception(data['message'] ?? 'Failed to fetch demo account data');
//       } else {
//         throw Exception('HTTP ${response.statusCode}: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching demo account data: $e');
//       rethrow;
//     }  
//   }

//   /// Switch account type: Demo to Real
//   /// POST /api/wallet/{user_id}
//   static Future<WalletData> switchToRealAccount({
//     required int userId,
//   }) async {
//     try {
//       final token = await TokenStorageService.getToken();
//       if (token == null) throw Exception('No authentication token found');

//       final url = Uri.parse('$baseUrl/wallet/$userId');
//       final body = {'account_type': 'LIVE'};

//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode(body),
//       );

//       print('POST $url → ${response.statusCode}');
//       print('Response: ${response.body}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body) as Map<String, dynamic>;
//         if (data['status'] == 'success') {
//           return WalletData.fromJson(data['data'] as Map<String, dynamic>);
//         }
//         throw Exception(data['message'] ?? 'Failed to switch to real account');
//       } else {
//         throw Exception('HTTP ${response.statusCode}: ${response.body}');
//       }
//     } catch (e) {
//       print('Error switching to real account: $e');
//       rethrow;
//     }
//   }
// }





// You’re seeing that because the favourites states overwrite the bloc state, and the All Pairs tab was rebuilding on those favourites states and falling into the “no data” branch.
// I’ve now changed AllPairsScreen so its BlocBuilder only rebuilds on all-pairs states (WatchBlocLoading, WatchBlocLoaded, WatchBlocError) and ignores favourites states, and its default branch returns an empty widget instead of clearing the list. This means:
// When you go to Favourites, WatchBloc emits FavouritesLoading/FavouritesLoaded, but the All Pairs tab does not rebuild.
// When you switch back to ALL, the previously built list of pairs is still shown without needing to reload or change tabs again.