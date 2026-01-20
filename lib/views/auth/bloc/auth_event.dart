part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}



final class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  LoginSubmitted({required this.email, required this.password});
}

final class RegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  RegisterSubmitted({required this.name, required this.email});
}

final class OtpSubmitted extends AuthEvent {
  final String code;
  final String email;
  OtpSubmitted({required this.code, required this.email});
}

final class PasswordSubmitted extends AuthEvent {
  final String password;
  final String confirmPasssword;
  PasswordSubmitted({required this.password, required this.confirmPasssword});
}

final class WhatsAppNumberSubmitted extends AuthEvent {
  final String whatsappNumber;
  WhatsAppNumberSubmitted({required this.whatsappNumber});
}

final class ForgotPasswordSubmitted extends AuthEvent {
  final String email;
  ForgotPasswordSubmitted(this.email);
}

final class LogoutRequested extends AuthEvent {
  LogoutRequested();
}

final class CheckAuthStatus extends AuthEvent {
  CheckAuthStatus();
}
