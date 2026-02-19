class TicketMessageDetail {
  final int ticketId;
  final String? message;
  final String? repliedMessage;

  TicketMessageDetail({
    required this.ticketId,
    this.message,
    this.repliedMessage,
  });

  factory TicketMessageDetail.fromJson(Map<String, dynamic> json) {
    return TicketMessageDetail(
      ticketId: json['ticket_id'] as int,
      message: json['message'] as String?,
      repliedMessage: json['replied_message'] as String?,
    );
  }
}