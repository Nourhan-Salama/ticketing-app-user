import 'package:flutter/material.dart';
import 'package:final_app/models/ticket-model.dart';

@immutable
abstract class TicketsState {}

class TicketsInitial extends TicketsState {}

class TicketsLoading extends TicketsState {}

class TicketsLoaded extends TicketsState {
  final List<TicketModel> tickets;
  final bool hasMore;
  final int currentPage;
  final int lastPage;
  final bool isFiltered;

  TicketsLoaded({
    required this.tickets,
    required this.hasMore,
    required this.currentPage,
    required this.lastPage,
    required this.isFiltered,
  });
}

class TicketsError extends TicketsState {
  final String message;
  TicketsError(this.message);
}

class TicketsEmpty extends TicketsState {}
