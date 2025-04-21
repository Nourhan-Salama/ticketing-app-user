import 'package:final_app/cubits/ticket-state.dart';
import 'package:final_app/models/ticket-model.dart';
import 'package:final_app/services/ticket-service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketsCubit extends Cubit<TicketsState> {
  final TicketService _ticketService;
  List<TicketModel> _allTickets = [];
  List<TicketModel> _filteredTickets = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = false;
  bool _isFiltered = false;

  TicketsCubit(this._ticketService) : super(TicketsInitial());

  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  bool get isFiltered => _isFiltered;

  Future<void> fetchTickets({bool refresh = false, int? page}) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      if (refresh) {
        _currentPage = 1;
        _allTickets.clear();
        _isFiltered = false;
        emit(TicketsLoading());
      }

      final pageToFetch = page ?? _currentPage;
      final result = await _ticketService.getPaginatedTickets(pageToFetch);
      final newTickets = result['tickets'] as List<TicketModel>;
      
      if (refresh) {
        _allTickets = newTickets;
      } else {
        _allTickets.addAll(newTickets);
      }
      
      _currentPage = result['current_page'];
      _lastPage = result['last_page'];
      _filteredTickets = List.from(_allTickets);

      emit(TicketsLoaded(
        tickets: _isFiltered ? _filteredTickets : _allTickets,
        hasMore: _currentPage < _lastPage && !_isFiltered,
        currentPage: _currentPage,
        lastPage: _lastPage,
        isFiltered: _isFiltered,
      ));
    } catch (e) {
      emit(TicketsError("Failed to load tickets: ${e.toString()}"));
    } finally {
      _isLoading = false;
    }
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || page > _lastPage) return;
    await fetchTickets(page: page);
  }

  Future<void> refreshTickets() async {
    await fetchTickets(refresh: true);
  }

  void filterTickets(int count) {
    if (count == 0) {
      _isFiltered = false;
      emit(TicketsLoaded(
        tickets: _allTickets,
        hasMore: _currentPage < _lastPage,
        currentPage: _currentPage,
        lastPage: _lastPage,
        isFiltered: false,
      ));
    } else {
      _isFiltered = true;
      _filteredTickets = _allTickets.take(count).toList();
      emit(TicketsLoaded(
        tickets: _filteredTickets,
        hasMore: false,
        currentPage: 1,
        lastPage: 1,
        isFiltered: true,
      ));
    }
  }

  void addTicket(TicketModel newTicket) {
    _allTickets.insert(0, newTicket);
    if (_isFiltered) {
      _filteredTickets.insert(0, newTicket);
    }
    emit(TicketsLoaded(
      tickets: _isFiltered ? _filteredTickets : _allTickets,
      hasMore: _currentPage < _lastPage && !_isFiltered,
      currentPage: _currentPage,
      lastPage: _lastPage,
      isFiltered: _isFiltered,
    ));
  }
}