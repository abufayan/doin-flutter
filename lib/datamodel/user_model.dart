import 'dart:convert';
import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  final int userId;
  final String username;
  final String email;
  final String? accountType; // 'LIVE' or 'DEMO'

  const UserModel({
    required this.userId,
    required this.username,
    required this.email,
    this.accountType,
  });

  // Convert from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final acct = (json['account_type'] ?? json['accountType'])?.toString();
    return UserModel(
      userId: json['user_id'] as int? ?? json['userId'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      accountType: acct != null && acct.isNotEmpty ? acct.toUpperCase() : 'LIVE',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'account_type': accountType ?? 'LIVE',
    };
  }

  // Convert to JSON string for storage
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Create from JSON string
  factory UserModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return UserModel.fromJson(json);
  }

  UserModel copyWith({
    int? userId,
    String? username,
    String? email,
    String? accountType,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      accountType: accountType ?? this.accountType,
    );
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, username: $username, email: $email, accountType: $accountType)';
  }
}
