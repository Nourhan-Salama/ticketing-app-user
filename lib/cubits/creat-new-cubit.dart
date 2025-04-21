import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_app/cubits/create-new-state.dart';
import 'package:final_app/services/ticket-service.dart';
import 'package:final_app/models/service-model.dart';

class CreateNewCubit extends Cubit<CreateNewState> {

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();

  final TicketService _ticketService = TicketService();

  CreateNewCubit() : super(CreateNewState.initial()) {
    _setupListeners();
    loadServices();
  }

  void _setupListeners() {
 
    descriptionController.addListener(_debouncedValidation);
    titleController.addListener(_debouncedValidation);
    serviceController.addListener(_debouncedValidation);
  }

  Timer? _debounceTimer;

  void _debouncedValidation() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), validateFields);
  }

  void validateFields() {
  
    final description = descriptionController.text.trim();
    final title = titleController.text.trim();

    var newState = state.copyWith(
   
       descriptionError: null,
   
      titleError: null,
      serviceError: null,
    
      descriptionSuccess: null,
   
      titleSuccess: null,
      serviceSuccess: null,
    );


    if (description.isEmpty || description.length < 10) {
      newState = newState.copyWith(descriptionError: 'At least 10 characters');
    } else {
      newState = newState.copyWith(descriptionSuccess: 'Good description');
    }

    if (title.isEmpty || title.length < 3) {
      newState = newState.copyWith(titleError: 'At least 3 characters');
    } else {
      newState = newState.copyWith(titleSuccess: 'Nice title');
    }

    if (state.selectedService == null) {
      newState = newState.copyWith(serviceError: 'Please choose a service');
    } else {
      newState = newState.copyWith(serviceSuccess: 'Service selected');
    }

    newState = newState.copyWith(
      isButtonEnabled:
    
          description.length >= 10 &&
          title.length >= 3 &&
          state.selectedService != null,
    );

    emit(newState);
  }

  Future<void> loadServices() async {
    try {
      emit(state.copyWith(isLoading: true));
      final services = await _ticketService.fetchServices();
      emit(state.copyWith(services: services, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        submissionError: 'Failed to load services: $e',
      ));
    }
  }

  void selectService(ServiceModel? service) {
    if (service != null) {
      serviceController.text = service.name;
      emit(state.copyWith(selectedService: service));
      validateFields();
    }
  }

  Future<void> submitForm(BuildContext context) async {
    if (!state.isButtonEnabled || state.selectedService == null) {
      emit(state.copyWith(submissionError: 'Please complete all fields correctly'));
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final response = await _ticketService.createTicket(
      
        description: descriptionController.text.trim(),
        title: titleController.text.trim(),
        serviceId: state.selectedService!.id.toString(),
      );

      if (response['success']) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ticket created successfully')),
        );
        Navigator.pushReplacementNamed(context, '/all-tickets');
      } else {
        emit(state.copyWith(
          isLoading: false,
          submissionError: response['message'] ?? 'Failed to create ticket',
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Unknown error')),
        );
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        submissionError: 'Submission failed: ${e.toString()}',
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Future<void> close() {
   
    descriptionController.dispose();
    titleController.dispose();
    serviceController.dispose();
    _debounceTimer?.cancel();
    return super.close();
  }
}


