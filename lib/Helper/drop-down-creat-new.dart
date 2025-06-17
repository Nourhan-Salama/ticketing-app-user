

import 'package:easy_localization/easy_localization.dart';
import 'package:final_app/Widgets/drawer.dart';
import 'package:final_app/Widgets/filter-dilog.dart';
import 'package:final_app/screens/create-new.dart';
import 'package:flutter/material.dart';
import 'package:final_app/util/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_app/cubits/tickets/get-ticket-cubits.dart';


class CustomDropDownCreateButton extends StatefulWidget {
  const CustomDropDownCreateButton({super.key});

  @override
  _CustomDropDownCreateButtonState createState() => _CustomDropDownCreateButtonState();
}

class _CustomDropDownCreateButtonState extends State<CustomDropDownCreateButton> {
  late List<String> filterOptions;
  late String currentFilter;

  @override
  void initState() {
    super.initState();
    filterOptions = ['allTickets'.tr(), 'filter'.tr(), 'resetFilter'.tr()];
    currentFilter = filterOptions[0];
  }
    Future<void> _showFilterDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const FilterDialog(),
    );

    if (result != null) {
      final ticketCubit = context.read<TicketsCubit>();
      
      // Fetch all tickets before applying filters
      await ticketCubit.fetchAllTickets();

      // Apply filters
      if (result['status'] != null) {
        ticketCubit.filterTicketsByStatus(result['status']);
      } else if (result['startDate'] != null && result['endDate'] != null) {
        ticketCubit.filterTicketsByDateTimeRange(
          startDate: result['startDate'],
          endDate: result['endDate'],
          startTime: result['enableTime'] ? result['startTime'] : null,
          endTime: result['enableTime'] ? result['endTime'] : null,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 150,
              child: DropdownButtonFormField<String>(
                value: currentFilter,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: filterOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (selectedValue) {
                  setState(() {
                    currentFilter = selectedValue!;
                  });
                  
                  final ticketCubit = context.read<TicketsCubit>();
                  if (selectedValue == filterOptions[0]) { // All Tickets
                    ticketCubit.fetchTickets(refresh: true);
                  } 
                  else if (selectedValue == filterOptions[1]) { // Filter
                    _showFilterDialog(context);
                  }
                  else if (selectedValue == filterOptions[2]) { // Reset
                    ticketCubit.resetFilters();
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsHelper.CreateNewButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, CreateNewScreen.routeName);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14)
                      ),
                      child: Icon(
                        Icons.add,
                        color: ColorsHelper.darkBlue,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'createNew'.tr(),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}