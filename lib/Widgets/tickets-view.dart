import 'package:final_app/cubits/ticket-state.dart';
import 'package:final_app/models/ticket-model.dart';
import 'package:final_app/screens/ticket-details.dart';
import 'package:final_app/services/ticket-service.dart';
import 'package:final_app/util/responsive-helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_app/cubits/get-ticket-cubits.dart';
import 'package:final_app/Widgets/data-tabel.dart';
import 'package:final_app/util/colors.dart';

class TicketsList extends StatefulWidget {
  const TicketsList({super.key, required List<TicketModel> tickets});

  @override
  State<TicketsList> createState() => _TicketsListState();
}

class _TicketsListState extends State<TicketsList> {
  Color _getStatusColor(int status) {
  switch (status) {
    case 0: return Colors.grey;
    case 1: return Colors.blue;
    case 2: return Colors.green;
    case 3: return Colors.red;
    default: return Colors.grey;
  }
}
  String _getStatusText(int status) {
  switch (status) {
    case 0: return 'Pending';
    case 1: return 'In Progress';
    case 2: return 'Resolved';
    case 3: return 'Closed';
    default: return 'Unknown';
  }
}

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketsCubit, TicketsState>(
      builder: (context, state) {
        if (state is TicketsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TicketsError) {
          return Center(
            child: Text(
              state.message,
              style: TextStyle(color: ColorsHelper.LightGrey),
            ),
          );
        } else if (state is TicketsLoaded) {
          if (state.tickets.isEmpty) {
            return Container(height: 0); // Invisible but preserves layout
          }

          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: ColorsHelper.LightGrey),
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.responsiveValue(
                  context: context,
                  mobile: 8,
                  tablet: 12,
                  desktop: 16,
                ),
              ),
            ),
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(
                color: ColorsHelper.LightGrey,
                thickness: 0.5,
                indent: 20,
                endIndent: 20,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.tickets.length,
              itemBuilder: (context, index) {
                final ticket = state.tickets[index];
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.responsiveValue(
                      context: context,
                      mobile: 12,
                      tablet: 16,
                      desktop: 20,
                    ),
                    vertical: ResponsiveHelper.responsiveValue(
                      context: context,
                      mobile: 8,
                      tablet: 12,
                      desktop: 16,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        final ticketService = context.read<TicketService>();
                        final ticketDetails =
                            await ticketService.getTicketDetails(ticket.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TicketDetailsScreen(ticket: ticketDetails),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Failed to load ticket details: $e')),
                        );
                      }
                    },
                    child: DataTableWidget(
                      title: ticket.title,
                      userName: ticket.user.name,
                      status: _getStatusText(ticket.status),
                      statusColor: _getStatusColor(ticket.status),
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const Center(child: Text("Unknown state"));
      },
    );
  }
}
