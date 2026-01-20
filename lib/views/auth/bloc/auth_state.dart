// ignore_for_file: must_be_immutable

part of 'auth_bloc.dart';

@immutable
sealed class AuthState {
   final RegisterData registerData;
   const AuthState(this.registerData);
}

@immutable
sealed class AuthActionState extends AuthState {
    const AuthActionState(super.registerData);

}

final class AuthInitial extends AuthState {
   AuthInitial() : super(const RegisterData());
}

final class LoginSuccess extends AuthActionState {
  final String message;
  const LoginSuccess(this.message, super.registerData);
}

final class OtpSentSuccessfully extends AuthActionState {
  final String message;
  const OtpSentSuccessfully(this.message, super.registerData);
}

final class AuthLoading extends AuthState {
  const AuthLoading(super.registerData);
}

final class AuthSuccess extends AuthActionState {
  const AuthSuccess(this.message, super.registerData);
  final String message;
}

final class UserRegisteredSuccessfully extends AuthActionState {
  const UserRegisteredSuccessfully(this.message, super.registerData);
  final String message;
}

final class OtpVerified extends AuthState {
  final String message;
  final String email;

  const OtpVerified(
    super.registerData, {
    required this.message,
    required this.email,
  });
}



final class AuthFailure extends AuthActionState {
  final String error;
  final String message;

  const AuthFailure({
    required this.error,
    required this.message,
    required RegisterData registerData,
  }) : super(registerData);
}

final class LoggedOut extends AuthActionState {
  const LoggedOut(super.registerData);
}

final class SessionRestored extends AuthActionState {
  final UserModel? user;
  const SessionRestored(super.registerData, {this.user});
}



