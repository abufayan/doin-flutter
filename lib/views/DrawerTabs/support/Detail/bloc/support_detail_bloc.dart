import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/DrawerTabs/support/Detail/datamodel/ticket_detail_model.dart';
import 'package:meta/meta.dart';

part 'support_detail_event.dart';

part 'support_detail_state.dart';

class SupportDetailBloc extends Bloc<SupportDetailEvent, SupportDetailState> {
  SupportDetailBloc() : super(SupportDetailInitial()) {
    on<SupportDetailEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<GetTicketDetails>(getTicketDetails);
  }

  FutureOr<void> getTicketDetails(
    GetTicketDetails event,
    Emitter<SupportDetailState> emit,
  ) async {
    try {
      emit(SupportDetailLoading());

      final response = await dio.get(
        baseUrl + getTicketDetailsUrl + event.ticketId.toString(),
      );

      final TicketMessageDetail ticket = TicketMessageDetail.fromJson(
        response.data,
      );

      emit(TicketLoaded(ticket: ticket));
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to load ticket';
      emit(ErrorLoadingTicket(message.toString()));
    } catch (e) {
      emit(ErrorLoadingTicket('Something went wrong'));
    }
  }
}
