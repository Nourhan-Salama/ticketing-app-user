class TicketStatistics {
  final int totalTickets;
  final int openTickets;
  final int closedTickets;

  TicketStatistics({
    required this.totalTickets,
    required this.openTickets,
    required this.closedTickets,
  });

  factory TicketStatistics.fromJson(Map<String, dynamic> json) {
    return TicketStatistics(
      totalTickets: json['all_tickets'] ?? 0,
      openTickets: json['opened_tickets'] ?? 0,
      closedTickets: json['closed_tickets'] ?? 0,
    );
  }
}

