import 'package:final_app/cubits/ticket-state.dart';
import 'package:final_app/models/ticket-model.dart';
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
    return status == 1 ? Colors.green : Colors.red;
  }

  String _getStatusText(int status) {
    return status == 1 ? 'Open' : 'Closed';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketsCubit, TicketsState>(
      builder: (context, state) {
        if (state is TicketsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        else if (state is TicketsError) {
          return Center(
            child: Text(
              state.message, 
              style: TextStyle(color: ColorsHelper.LightGrey),
            ),
          );
        }
        else if (state is TicketsEmpty) {
          return Center(
            child: Text(
              'No tickets available',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        else if (state is TicketsLoaded) {
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
                  child: DataTableWidget(
                    description: ticket.description,
                    userName: ticket.user.name,
                    status: _getStatusText(ticket.status),
                    statusColor: _getStatusColor(ticket.status),
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