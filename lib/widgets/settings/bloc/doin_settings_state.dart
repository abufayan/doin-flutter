part of 'doin_settings_bloc.dart';

@immutable
sealed class DoinSettingsState {}

final class DoinSettingsInitial extends DoinSettingsState {}

final class DoinSettingsLoading extends DoinSettingsState {}

final class DoinSettingsError extends DoinSettingsState {
  final String message;
  DoinSettingsError(this.message);
}

@immutable
sealed class DoinSettingsActionState extends DoinSettingsState {
  DoinSettingsActionState();
}

final class LoggedOutSuccessfully extends DoinSettingsActionState {
  LoggedOutSuccessfully();
}