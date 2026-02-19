part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class LoadProfileEvent extends ProfileEvent {}

class OnSubmit extends ProfileEvent {
  final Map<String, dynamic> formData;

  OnSubmit({required this.formData});
}