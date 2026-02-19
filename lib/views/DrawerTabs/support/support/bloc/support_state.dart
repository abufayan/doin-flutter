part of 'support_bloc.dart';

@immutable
sealed class SupportState {}

class SupportInitial extends SupportState {}

class SupportLoading extends SupportState {}

class SupportLoaded extends SupportState {
  final List<SupportTicket> tickets;
  final ContactData? contactData;
  final String message;
  SupportLoaded({
    required this.message,
    required this.tickets,
    this.contactData,
  });
}

class SupportSuccess extends SupportState {
  final String message;
  SupportSuccess(this.message);
}

class SupportEmpty extends SupportState {
  final ContactData? contactData;
  SupportEmpty({this.contactData});
}

class SupportError extends SupportState {
  final String message;
  SupportError(this.message);
}
