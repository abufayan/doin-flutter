import 'package:doin_fx/core/services/token_storage_service.dart';
import 'package:doin_fx/datamodel/user_model.dart';

/// Helper class for authentication-related operations
class AuthHelper {
  /// Get current authenticated user
  static Future<UserModel?> getCurrentUser() async {
    return await TokenStorageService.getUser();
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    return await TokenStorageService.isAuthenticated();
  }

  /// Get authentication token
  static Future<String?> getToken() async {
    return await TokenStorageService.getToken();
  }

  /// Logout - clears all stored authentication data
  static Future<void> logout() async {
    await TokenStorageService.clearTokens();
  }
}
