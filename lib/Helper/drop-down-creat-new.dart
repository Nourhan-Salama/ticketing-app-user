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
  List<String> filterOptions = ['None', '5', '10'];
  String currentFilter = 'None';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 100,
              child: DropdownButtonFormField<String>(
                value: currentFilter,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: filterOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (selectedValue) {
                  setState(() {
                    currentFilter = selectedValue!;
                  });
                  
                  final ticketCubit = context.read<TicketsCubit>();
                  if (selectedValue == 'None') {
                    ticketCubit.filterTickets(0);
                  } else {
                    ticketCubit.filterTickets(int.parse(selectedValue!));
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