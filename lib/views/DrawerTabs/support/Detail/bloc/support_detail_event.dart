part of 'support_detail_bloc.dart';

@immutable
sealed class SupportDetailEvent {}

class GetTicketDetails extends SupportDetailEvent {
  final String ticketId;
  GetTicketDetails({required this.ticketId});
}




