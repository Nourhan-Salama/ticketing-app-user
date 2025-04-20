import 'package:final_app/models/ticket-model.dart';
import 'package:flutter/material.dart';

@immutable
abstract class TicketsState {}

class TicketsInitial extends TicketsState {}

class TicketsLoading extends TicketsState {}

class TicketsLoaded extends TicketsState {
  final List<TicketModel> tickets;
  TicketsLoaded(this.tickets);
}

class TicketsEmpty extends TicketsState {}

class TicketsError extends TicketsState {
  final String message;
  TicketsError(this.message);
}

