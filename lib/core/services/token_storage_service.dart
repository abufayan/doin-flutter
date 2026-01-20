import 'package:doin_fx/datamodel/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  /// Save authentication token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Get authentication token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Save refresh token (if your API uses refresh tokens)
  static Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save user data
  static Future<void> saveUser(UserModel user) async {
    await _storage.write(key: _userKey, value: user.toJsonString());
  }

  /// Get user data
  static Future<UserModel?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson == null || userJson.isEmpty) {
      return null;
    }
    try {
      return UserModel.fromJsonString(userJson);
    } catch (e) {
      return null;
    }
  }

  /// Clear all tokens (logout)
  static Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }

  /// Clear all stored data
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
