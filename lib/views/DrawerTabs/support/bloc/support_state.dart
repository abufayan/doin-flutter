part of 'support_bloc.dart';

@immutable
sealed class SupportState {}

class SupportInitial extends SupportState {}

class SupportLoading extends SupportState {}

class SupportLoaded extends SupportState {
  final List<SupportTicket> tickets;
  SupportLoaded(this.tickets);
}

class SupportEmpty extends SupportState {}

class SupportError extends SupportState {
  final String message;
  SupportError(this.message);
}

