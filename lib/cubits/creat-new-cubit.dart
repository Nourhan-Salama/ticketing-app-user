import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_app/cubits/create-new-state.dart';
import 'package:final_app/services/ticket-service.dart';
import 'package:final_app/models/service-model.dart';

class CreateNewCubit extends Cubit<CreateNewState> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();

  final TicketService _ticketService = TicketService();

  CreateNewCubit() : super(CreateNewState.initial()) {
    _setupListeners();
    loadServices();
  }

  void _setupListeners() {
    firstNameController.addListener(_debouncedValidation);
    lastNameController.addListener(_debouncedValidation);
    emailController.addListener(_debouncedValidation);
    departmentController.addListener(_debouncedValidation);
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
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final department = departmentController.text.trim();
    final description = descriptionController.text.trim();
    final title = titleController.text.trim();

    var newState = state.copyWith(
      firstNameError: null,
      lastNameError: null,
      emailError: null,
      descriptionError: null,
      departmentError: null,
      titleError: null,
      serviceError: null,
      firstNameSuccess: null,
      lastNameSuccess: null,
      emailSuccess: null,
      descriptionSuccess: null,
      departmentSuccess: null,
      titleSuccess: null,
      serviceSuccess: null,
    );

    if (firstName.isEmpty || firstName.length < 2) {
      newState = newState.copyWith(firstNameError: 'At least 2 characters');
    } else {
      newState = newState.copyWith(firstNameSuccess: 'Looks good!');
    }

    if (lastName.isEmpty || lastName.length < 2) {
      newState = newState.copyWith(lastNameError: 'At least 2 characters');
    } else {
      newState = newState.copyWith(lastNameSuccess: 'Looks good!');
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      newState = newState.copyWith(emailError: 'Invalid email format');
    } else {
      newState = newState.copyWith(emailSuccess: 'Valid email');
    }

    if (department.isEmpty) {
      newState = newState.copyWith(departmentError: 'Please select department');
    } else {
      newState = newState.copyWith(departmentSuccess: 'Selected');
    }

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
      isButtonEnabled: firstName.isNotEmpty &&
          lastName.isNotEmpty &&
          emailRegex.hasMatch(email) &&
          department.isNotEmpty &&
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
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        department: departmentController.text.trim(),
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
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    departmentController.dispose();
    descriptionController.dispose();
    titleController.dispose();
    serviceController.dispose();
    _debounceTimer?.cancel();
    return super.close();
  }
}


