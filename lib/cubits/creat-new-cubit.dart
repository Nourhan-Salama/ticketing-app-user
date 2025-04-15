import 'package:final_app/cubits/get-ticket-cubits.dart';
import 'package:final_app/models/ticket-model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateNewCubit extends Cubit<bool> {
  CreateNewCubit() : super(false) {
    for (var controller in controllers.values) {
      controller.addListener(checkFields);
    }
  }

  final Map<String, TextEditingController> controllers = {
    'firstName': TextEditingController(),
    'lastName': TextEditingController(),
    'email': TextEditingController(),
    'department': TextEditingController(),
    'richText': TextEditingController(),
  };

  void checkFields() {
    final allFilled = controllers.values.every((c) => c.text.trim().isNotEmpty);
    if (!isClosed) emit(allFilled);
  }

  void submitForm(BuildContext context) {
    if (!state) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Color(0xFFB3B3B3),
        ),
      );
      return;
    }

    final newTicket = TicketModel(
      description: controllers["richText"]!.text.trim(),
      userName: "${controllers["firstName"]!.text.trim()} "
          "${controllers["lastName"]!.text.trim()}",
      status: "Pending",
      statusColor: Colors.grey,
    );

    try {
      context.read<TicketsCubit>().addTicket(newTicket);
      _clearForm();
      _showSuccessFeedback(context);
    } catch (e) {
      _handleError(context, e);
    }
  }

  void _clearForm() {
    for (final controller in controllers.values) {
      controller.clear();
    }
    checkFields();
  }

  void _showSuccessFeedback(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ticket Created Successfully!'),
        backgroundColor: Color(0xFF051754),
      ),
    );
    // Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/all-tickets');

  }

  void _handleError(BuildContext context, dynamic error) {
    debugPrint("Ticket submission error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to create ticket'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  @override
  Future<void> close() {
    debugPrint("CreateNewCubit disposed");
    for (final controller in controllers.values) {
      controller.dispose();
    }
    return super.close();
  }
}






