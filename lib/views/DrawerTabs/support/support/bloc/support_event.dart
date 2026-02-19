part of 'support_bloc.dart';

@immutable
sealed class SupportEvent {}

class LoadTickets extends SupportEvent {}

class CreateTicketPressed extends SupportEvent {
  final String description;
  final String subject;
  final String imagePath;

  CreateTicketPressed({required this.description, required this.subject, required this.imagePath});
}

class LoadContactInfo extends SupportEvent {}

class LoadSupportOverview extends SupportEvent {}
