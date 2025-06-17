import 'dart:async';
import 'dart:io';
import 'package:final_app/cubits/tickets/ticket-state.dart';
import 'package:final_app/models/ticket-details-model.dart';
import 'package:final_app/models/ticket-model.dart';
import 'package:final_app/services/ticket-service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class TicketsCubit extends Cubit<TicketsState> {
  final TicketService _ticketService;
  List<TicketModel> _allTickets = [];
  List<TicketModel> _filteredTickets = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = false;
  bool _isFiltered = false;
  String _currentSearchQuery = '';

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
        _filteredTickets.clear();
        _isFiltered = false;
        _currentSearchQuery = '';
      }

      final currentPageToFetch = page ?? _currentPage;
      emit(TicketsLoading());

      final response = await _ticketService.getPaginatedTickets(currentPageToFetch);

      _currentPage = response['current_page'] ?? 1;
      _lastPage = response['last_page'] ?? 1;
      
      // Safe handling of tickets data
      final dynamic ticketsData = response['tickets'];
      List<TicketModel> newTickets = [];
      
      if (ticketsData != null && ticketsData is List) {
        newTickets = ticketsData.cast<TicketModel>();
      }

      if (refresh) {
        _allTickets = newTickets;
      } else {
        _allTickets.addAll(newTickets);
      }

      if (_allTickets.isEmpty) {
        emit(TicketsEmpty());
      } else {
        emit(TicketsLoaded(
          tickets: _isFiltered ? _filteredTickets : _allTickets,
          currentPage: _currentPage,
          lastPage: _lastPage,
          hasMore: _currentPage < _lastPage,
          isFiltered: _isFiltered,
        ));
      }
    } catch (e) {
      print('❌ Error fetching tickets: $e');
      emit(TicketsError('Failed to load tickets'));
    } finally {
      _isLoading = false;
    }
  }

  void searchTickets(String query) {
    _currentSearchQuery = query;
    
    if (query.isEmpty) {
      _isFiltered = false;
      emit(TicketsLoaded(
        tickets: _allTickets,
        hasMore: _currentPage < _lastPage,
        currentPage: _currentPage,
        lastPage: _lastPage,
        isFiltered: false,
      ));
      return;
    }

    _isFiltered = true;
    _filteredTickets = _filterTickets(_allTickets, query);
    
    emit(TicketsLoaded(
      tickets: _filteredTickets,
      hasMore: false,
      currentPage: _currentPage,
      lastPage: _lastPage,
      isFiltered: true,
    ));
  }

  List<TicketModel> _filterTickets(List<TicketModel> tickets, String query) {
    final lowerCaseQuery = query.toLowerCase();
    return tickets.where((ticket) {
      return ticket.title.toLowerCase().contains(lowerCaseQuery) ||
          ticket.id.toString().contains(lowerCaseQuery);
    }).toList();
  }

  Future<TicketDetailsModel> getTicketDetails(int ticketId) async {
    try {
      return await _ticketService.getTicketDetails(ticketId);
    } catch (e) {
      print('❌ Error fetching ticket details: $e');
      rethrow;
    }
  }
  
  Future<TicketModel> getTicketById(int ticketId) async {
    try {
      return await _ticketService.getTicketById(ticketId);
    } catch (e) {
      throw Exception('Failed to fetch ticket: $e');
    }
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || page > _lastPage) return;
    await fetchTickets(page: page);
  }

  Future<void> refreshTickets() async {
    await fetchTickets(refresh: true);
  }

  void filterTicketsByStatus(int status) {
    _isFiltered = true;
    _filteredTickets = _allTickets.where((ticket) => ticket.status == status).toList();
    
    emit(TicketsLoaded(
      tickets: _filteredTickets,
      hasMore: false,
      currentPage: 1,
      lastPage: 1,
      isFiltered: true,
    ));
  }

  void resetFilters() {
    _isFiltered = false;
    _currentSearchQuery = '';
    emit(TicketsLoaded(
      tickets: _allTickets,
      hasMore: _currentPage < _lastPage,
      currentPage: _currentPage,
      lastPage: _lastPage,
      isFiltered: false,
    ));
  }

  void filterTicketsByDateTimeRange({
    required DateTime startDate,
    required DateTime endDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    _isFiltered = true;
    
    _filteredTickets = _allTickets.where((ticket) {
      final ticketDate = ticket.createdAt;
      bool dateMatches = ticketDate.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
                         ticketDate.isBefore(endDate.add(const Duration(days: 1)));
      
      bool timeMatches = true;
      if (startTime != null && endTime != null) {
        final ticketTime = TimeOfDay.fromDateTime(ticketDate);
        timeMatches = _isTimeOfDayAfter(ticketTime, startTime) && 
                      _isTimeOfDayBefore(ticketTime, endTime);
      }
      
      return dateMatches && timeMatches;
    }).toList();

    emit(TicketsLoaded(
      tickets: _filteredTickets,
      hasMore: false,
      currentPage: 1,
      lastPage: 1,
      isFiltered: true,
    ));
  }

  bool _isTimeOfDayAfter(TimeOfDay a, TimeOfDay b) {
    return a.hour > b.hour || (a.hour == b.hour && a.minute >= b.minute);
  }

  bool _isTimeOfDayBefore(TimeOfDay a, TimeOfDay b) {
    return a.hour < b.hour || (a.hour == b.hour && a.minute <= b.minute);
  }

  Future<void> fetchAllTickets() async {
    if (_isLoading) return;
    _isLoading = true;
    emit(TicketsLoading());

    try {
      final response = await _ticketService.getAllTickets();
      _allTickets = response;
      _currentPage = 1;
      _lastPage = 1;

      emit(TicketsLoaded(
        tickets: _allTickets,
        currentPage: 1,
        lastPage: 1,
        hasMore: false,
        isFiltered: false,
      ));
    } catch (e) {
      print('❌ Error fetching all tickets: $e');
      emit(TicketsError('Failed to load tickets'));
    } finally {
      _isLoading = false;
    }
  }
}