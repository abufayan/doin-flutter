part of 'change_password_bloc.dart';

@immutable
sealed class ChangePasswordState {}

final class ChangePasswordInitial extends ChangePasswordState {}

final class ChangePasswordLoading extends ChangePasswordState {}

final class ChangePasswordSuccess extends ChangePasswordState {
  final String message;

  ChangePasswordSuccess({required this.message});
}

final class ChangePasswordError extends ChangePasswordState {
  final String message;

  ChangePasswordError({required this.message});
}

final class PasswordMismatchError extends ChangePasswordState {
  final String message;

  PasswordMismatchError({required this.message});
}

