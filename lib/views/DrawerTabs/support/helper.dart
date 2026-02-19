import 'package:doin_fx/core/enums.dart';
import 'package:intl/intl.dart';

extension TicketStatusExtension on TicketStatus {
  String get value {
    switch (this) {
      case TicketStatus.open:
        return 'open';
      case TicketStatus.closed:
        return 'closed';
    }
  }

  static TicketStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'open':
        return TicketStatus.open;
      case 'closed':
        return TicketStatus.closed;
      default:
        return TicketStatus.open; // safe fallback
    }
  }
}



String formatCreatedAt(
    DateTime dateTime, {
      bool withTime = false,
    }) {
  final DateTime local = dateTime.toLocal();

  if (withTime) {
    // 24-hour format
    return DateFormat('dd MMM yyyy, HH:mm').format(local);
  }

  // Date only
  return DateFormat('dd MMM yyyy').format(local);
}

