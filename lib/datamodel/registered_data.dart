import 'package:flutter/foundation.dart';


@immutable
class RegisterData {
  final String? username;
  final String? email;
  final bool otpVerified;
  final String? password;
  final String? confirmPassword;
  final String? whatsappNumber;

  const RegisterData({
    this.username,
    this.email,
    this.otpVerified = false,
    this.password,
    this.confirmPassword,
    this.whatsappNumber,
  });

  RegisterData copyWith({
    String? username,
    String? email,
    bool? otpVerified,
    String? password,
    String? confirmPassword,
    String? whatsappNumber,
  }) {
    return RegisterData(
      username: username ?? this.username,
      email: email ?? this.email,
      otpVerified: otpVerified ?? this.otpVerified,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
    );
  }
}
