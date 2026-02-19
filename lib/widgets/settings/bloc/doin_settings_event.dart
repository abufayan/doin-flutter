part of 'doin_settings_bloc.dart';

@immutable
sealed class DoinSettingsEvent {}

class LogoutEvent extends DoinSettingsEvent {}