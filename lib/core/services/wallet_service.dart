import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/core/services/token_storage_service.dart';
import 'package:doin_fx/datamodel/account_response.dart';
import 'package:doin_fx/setup.dart';

/// 🔑 Wallet Service - Centralized wallet/margin data management
class WalletService {
  /// Fetch fresh wallet and margin data from server
  /// Respects current account type (LIVE/DEMO)
  static Future<WalletResponse?> refreshWallet() async {
    try {
      // Get the latest user data from storage to check account type
      final user = await TokenStorageService.getUser();
      if (user == null) {
        return null;
      }

      final userId = user.userId.toString();
      final accountType = (user.accountType ?? 'LIVE').toUpperCase();

      // Use different URL based on account type
      final url = accountType == 'DEMO'
          ? baseUrl + getDemoWalletBalance + userId
          : baseUrl + getRealWalletBalance + userId;

      final response = await dio.get(url);
      final WalletResponse wallet = WalletResponse.fromJson(response.data);

      if (wallet.status == 'success') {
        return wallet;
      } else {}
    } catch (e) {}
    return null;
  }

  /// Update MyAccountService with fresh wallet data
  /// Also handles account switching (LIVE/DEMO)
  static Future<void> updateAccountService() async {
    try {
      final wallet = await refreshWallet();

      if (wallet != null) {
        // 🔑 Update MyAccountService with fresh data
        await getIt<MyAccountService>().setValues(
          gotWallet: wallet.wallet.toStringAsFixed(2),
          usedMargin: wallet.used_margin.toString(),
        );
      } else {}
    } catch (e) {}
  }
}
