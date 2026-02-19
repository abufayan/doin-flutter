import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/DrawerTabs/support/datamodel/ticket.dart';
import 'package:doin_fx/datamodel/contact_response.dart';
import 'package:meta/meta.dart';

part 'support_event.dart';
part 'support_state.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  ContactData? _contactDataCache;

  SupportBloc() : super(SupportInitial()) {
    on<LoadTickets>(_loadTickets);
    on<CreateTicketPressed>(_createTicket);
    on<LoadContactInfo>(_loadContactInfo);
    on<LoadSupportOverview>(_loadSupportOverview);
  }

  Future<void> _createTicket(
    CreateTicketPressed event,
    Emitter<SupportState> emit,
  ) async {
    emit(SupportLoading());

    try {
      var myAccount = getIt<MyAccountService>();

      Map<String, dynamic> data = {
        'user_id': myAccount.user!.userId,
        'username': myAccount.user!.username,
        'email': myAccount.user!.email,
        'subject': event.subject,
        'message': event.description,
      };

      if (event.imagePath.isNotEmpty) {
        data['message_img'] = await MultipartFile.fromFile(
          event.imagePath,
          filename: event.imagePath.split('/').last,
        );
      }

      final formData = FormData.fromMap(data);

      await dio.post(baseUrl + createTicket, data: formData);

      emit(SupportSuccess('Ticket created successfully'));
    } catch (e) {
      final message = (e is DioException && e.response?.data is Map)
          ? e.response?.data['message']?.toString() ?? 'Something went wrong'
          : 'Something went wrong';
      emit(SupportError(message));
    }
  }

  Future<void> _loadTickets(
    LoadTickets event,
    Emitter<SupportState> emit,
  ) async {
    emit(SupportLoading());

    try {
      final response = await dio.get(
        '$baseUrl$getTickets${getIt<MyAccountService>().user?.userId}',
      );

      // response.data is a List<dynamic>
      final List<SupportTicket> tickets = (response.data as List)
          .map((e) => SupportTicket.fromJson(e as Map<String, dynamic>))
          .toList();

      if (tickets.isEmpty) {
        emit(SupportEmpty(contactData: _contactDataCache));
      } else {
        emit(
          SupportLoaded(
            tickets: tickets,
            contactData: _contactDataCache,
            message: 'Tickets loaded successfully',
          ),
        );
      }
    } catch (e) {
      final message = (e is DioException && e.response?.data is Map)
          ? e.response?.data['message']?.toString() ?? 'Something went wrong'
          : 'Something went wrong';
      emit(SupportError(message));
    }
  }

  Future<void> _loadContactInfo(
    LoadContactInfo event,
    Emitter<SupportState> emit,
  ) async {
    try {
      final response = await dio.get(baseUrl + getContactInfo);
      final contactResponse = ContactResponse.fromJson(response.data);

      if (contactResponse.data.isNotEmpty) {
        _contactDataCache = contactResponse.data.first;
        if (state is SupportLoaded) {
          final s = state as SupportLoaded;
          emit(
            SupportLoaded(
              tickets: s.tickets,
              contactData: _contactDataCache,
              message: s.message,
            ),
          );
        } else if (state is SupportInitial || state is SupportLoading) {
          // If we are still loading tickets, just cache it for now
          // The LoadTickets will emit it later
        }
      }
    } catch (e) {
      // We don't necessarily want to emit error for the whole screen if just contact info fails
    }
  }

  Future<void> _loadSupportOverview(
    LoadSupportOverview event,
    Emitter<SupportState> emit,
  ) async {
    add(LoadTickets());
    add(LoadContactInfo());
  }
}
