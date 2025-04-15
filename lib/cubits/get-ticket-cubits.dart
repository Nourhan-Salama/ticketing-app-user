// get-ticket-cubits.dart
import 'package:final_app/cubits/ticket-state.dart';
import 'package:final_app/models/ticket-model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketsCubit extends Cubit<TicketsState> {
  TicketsCubit() : super(TicketsInitial());

  final List<TicketModel> _tickets = [];

  void fetchTickets() {
    emit(TicketsLoading());
    try {
      if (_tickets.isEmpty) {
        emit(TicketsEmpty());
      } else {
        emit(TicketsLoaded(List.from(_tickets)));
      }
    } catch (e) {
      emit(TicketsError("Failed to load tickets"));
    }
  }

  void addTicket(TicketModel newTicket) {
    _tickets.add(newTicket);
    emit(TicketsLoaded(List.from(_tickets)));
  }


}