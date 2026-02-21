part of 'change_password_bloc.dart';

@immutable
sealed class ChangePasswordEvent {}



final class LoadData extends ChangePasswordEvent {}


final class ChangePasswordSubmitted extends ChangePasswordEvent {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordSubmitted({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });
}

