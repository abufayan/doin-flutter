import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/views/DrawerTabs/support/helper.dart';

class SupportTicket {
  final int ticketId;
  final int userId;
  final String subject;
  final DateTime createdAt;
  final TicketStatus status;

  SupportTicket({
    required this.ticketId,
    required this.userId,
    required this.subject,
    required this.createdAt,
    required this.status,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      ticketId: json['ticket_id'] as int,
      userId: json['user_id'] as int,
      subject: json['subject'] as String,
      createdAt: DateTime.parse(json['created_at']),
      status: TicketStatusExtension.fromString(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticket_id': ticketId,
      'user_id': userId,
      'subject': subject,
      'created_at': createdAt.toIso8601String(),
      'status': status.value,
    };
  }
}

