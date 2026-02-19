part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileFailure extends ProfileState {
  final String error;

  ProfileFailure(this.error);
}

final class ProfileLoaded extends ProfileState {
  final String message;
  final Map<String, dynamic> initialValue;

  ProfileLoaded({required this.message, required this.initialValue});
}

final class ProfileUpdated extends ProfileState {
  final String message;

  ProfileUpdated({required this.message});
}

