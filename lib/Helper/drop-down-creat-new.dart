import 'package:final_app/screens/create-new.dart';
import 'package:flutter/material.dart';
import 'package:final_app/util/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_app/cubits/get-ticket-cubits.dart';

class CustomDropDownCreateButton extends StatefulWidget {
  const CustomDropDownCreateButton({super.key});

  @override
  _CustomDropDownCreateButtonState createState() => _CustomDropDownCreateButtonState();
}

class _CustomDropDownCreateButtonState extends State<CustomDropDownCreateButton> {
  List<String> filterOptions = ['All Tickets', 'Last 5 Tickets', 'Last 10 Tickets'];
  String currentFilter = 'All Tickets';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 150, // Increased width for better visibility
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
                      style: TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (selectedValue) {
                  setState(() {
                    currentFilter = selectedValue!;
                  });
                  
                  final ticketCubit = context.read<TicketsCubit>();
                  switch (selectedValue) {
                    case 'All Tickets':
                      ticketCubit.fetchTickets(refresh: true);
                      break;
                    case 'Last 5 Tickets':
                      ticketCubit.filterTickets(5);
                      break;
                    case 'Last 10 Tickets':
                      ticketCubit.filterTickets(10);
                      break;
                    default:
                      ticketCubit.fetchTickets(refresh: true);
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
                      'Create New',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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