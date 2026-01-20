import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'pending_order_event.dart';
part 'pending_order_state.dart';

class PendingOrderBloc extends Bloc<PendingOrderEvent, PendingOrderState> {
  PendingOrderBloc() : super(PendingOrderInitial()) {
    on<PendingOrderEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
