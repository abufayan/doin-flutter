import 'package:bloc/bloc.dart';
import 'package:doin_fx/views/DrawerTabs/support/datamodel/ticket.dart';
import 'package:meta/meta.dart';

part 'support_event.dart';
part 'support_state.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  SupportBloc() : super(SupportInitial()) {
    on<LoadTickets>(_loadTickets);
  }

  Future<void> _loadTickets(
      LoadTickets event,
      Emitter<SupportState> emit,
      ) async {
    emit(SupportLoading());

    // TODO: Replace with API call
    await Future.delayed(const Duration(seconds: 1));

    final tickets = <SupportTicket>[]; // empty for now

    if (tickets.isEmpty) {
      emit(SupportEmpty());
    } else {
      emit(SupportLoaded(tickets));
    }
  }
}
