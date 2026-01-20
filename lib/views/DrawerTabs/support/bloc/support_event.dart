part of 'support_bloc.dart';

@immutable
sealed class SupportEvent {}

class LoadTickets extends SupportEvent {}

class CreateTicketPressed extends SupportEvent {}
