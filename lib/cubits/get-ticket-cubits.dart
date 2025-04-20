import 'package:final_app/cubits/ticket-state.dart';
import 'package:final_app/models/ticket-model.dart';
import 'package:final_app/services/ticket-service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketsCubit extends Cubit<TicketsState> {
  final TicketService _ticketService;

  TicketsCubit(this._ticketService) : super(TicketsInitial());

  Future<void> fetchTickets() async {
    emit(TicketsLoading());
    try {
      final tickets = await _ticketService.getAllTickets();
      if (tickets.isEmpty) {
        emit(TicketsEmpty());
      } else {
        emit(TicketsLoaded(tickets));
      }
    } catch (e) {
      emit(TicketsError("Failed to load tickets: ${e.toString()}"));
    }
  }

  void addTicket(TicketModel newTicket) {
    if (state is TicketsLoaded) {
      final currentState = state as TicketsLoaded;
      emit(TicketsLoaded([newTicket, ...currentState.tickets]));
    }
  }
}