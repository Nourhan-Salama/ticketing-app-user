import 'package:final_app/cubits/ticket-state.dart';
import 'package:final_app/models/ticket-model.dart';
import 'package:final_app/services/ticket-service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketsCubit extends Cubit<TicketsState> {
  final TicketService _ticketService;
  List<TicketModel> _allTickets = [];

  TicketsCubit(this._ticketService) : super(TicketsInitial());

  Future<void> fetchTickets() async {
    emit(TicketsLoading());
    try {
      _allTickets = await _ticketService.getAllTickets();
      emit(TicketsLoaded(_allTickets)); // Always emit loaded state
    } catch (e) {
      emit(TicketsError("Failed to load tickets: ${e.toString()}"));
    }
  }

  void filterTickets(int count) {
    if (count == 0) {
      emit(TicketsLoaded([])); // Empty list instead of TicketsEmpty
    } else {
      final filteredTickets = _allTickets.take(count).toList();
      emit(TicketsLoaded(filteredTickets));
    }
  }

  void addTicket(TicketModel newTicket) {
    _allTickets.insert(0, newTicket);
    emit(TicketsLoaded([newTicket, ..._allTickets]));
  }
}