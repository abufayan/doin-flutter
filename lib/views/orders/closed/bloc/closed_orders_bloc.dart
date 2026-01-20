import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'closed_orders_event.dart';
part 'closed_orders_state.dart';

class ClosedOrdersBloc extends Bloc<ClosedOrdersEvent, ClosedOrdersState> {
  ClosedOrdersBloc() : super(ClosedOrdersInitial()) {
    on<ClosedOrdersEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
