part of 'support_detail_bloc.dart';

@immutable
sealed class SupportDetailState {}

final class SupportDetailInitial extends SupportDetailState {}


final class SupportDetailLoading extends SupportDetailState {}

final class ErrorLoadingTicket extends SupportDetailState {
  final String message;

  ErrorLoadingTicket(this.message);
}


final class TicketLoaded extends SupportDetailState {
  final TicketMessageDetail ticket;

  TicketLoaded({required this.ticket});
}

