
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:final_app/Widgets/drawer.dart';
import 'package:final_app/models/ticket-model.dart';
import 'package:final_app/models/section-model.dart';
import 'package:final_app/services/setion-service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_app/cubits/createNewTicket/create-new-state.dart';
import 'package:final_app/services/ticket-service.dart';
import 'package:final_app/models/service-model.dart';

class CreateNewCubit extends Cubit<CreateNewState> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final TicketService _ticketService = TicketService();
  final ApiService _apiService = ApiService();
  Timer? _debounceTimer;

  int? ticketId;
  final TicketModel? ticket;

  CreateNewCubit({this.ticket}) : super(CreateNewState.initial()) {
    _setupListeners();
    _loadServicesAndInitialize();
  }

  void _loadServicesAndInitialize() async {
    try {
      final services = await _ticketService.fetchServices();
      
      ServiceModel? initialService;
      SectionModel? initialSection;
      
      if (ticket != null) {
        initialService = services.firstWhere(
          (s) => s.id == ticket!.service.id,
          orElse: () => services.isNotEmpty ? services[0] : ServiceModel.empty(),
        );
        
        // Load sections for the initial service if ticket exists
        if (initialService != null && initialService.id != -1) {
          try {
            final sections = await _apiService.fetchSections(initialService.id);
            // If ticket has section info, find the matching section
            // Assuming ticket model has section info - adjust accordingly
            emit(state.copyWith(
              services: services,
              selectedService: initialService,
              sections: sections,
              selectedSection: sections.isNotEmpty ? sections[0] : null,
            ));
          } catch (e) {
            emit(state.copyWith(
              services: services,
              selectedService: initialService,
              sectionError: 'Failed to load sections',
            ));
          }
        }
      } else {
        emit(state.copyWith(
          services: services,
          selectedService: initialService,
        ));
      }
      
      if (ticket != null) {
        loadTicket(ticket!);
      }
    } catch (e) {
      emit(state.copyWith(
        submissionError: 'Failed to load services: $e',
      ));
    }
  }

  void _setupListeners() {
    descriptionController.addListener(_debouncedValidation);
    titleController.addListener(_debouncedValidation);
  }

  void loadTicket(TicketModel ticket) {
    titleController.text = ticket.title;
    descriptionController.text = ticket.description;
    ticketId = ticket.id;
    validateFields();
  }

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
      sectionError: null,
      descriptionSuccess: null,
      titleSuccess: null,
      serviceSuccess: null,
      sectionSuccess: null,
    );

    if (description.isEmpty || description.length < 10) {
      newState = newState.copyWith(descriptionError: 'At least 10 characters');
    } else {
      newState = newState.copyWith(descriptionSuccess: 'goodDescription'.tr());
    }

    if (title.isEmpty || title.length < 3) {
      newState = newState.copyWith(titleError: 'At least 3 characters');
    } else {
      newState = newState.copyWith(titleSuccess: 'niceTitle'.tr());
    }

    if (state.selectedService == null) {
      newState = newState.copyWith(serviceError: 'Please choose a service');
    } else {
      newState = newState.copyWith(serviceSuccess: 'serviceSelected'.tr());
    }

    if (state.selectedSection == null && state.sections.isNotEmpty) {
      newState = newState.copyWith(sectionError: 'Please choose a section');
    } else if (state.selectedSection != null) {
      newState = newState.copyWith(sectionSuccess: 'sectionSelected'.tr());
    }

    newState = newState.copyWith(
      isButtonEnabled: description.length >= 10 &&
          title.length >= 3 &&
          state.selectedService != null &&
          (state.sections.isEmpty || state.selectedSection != null),
    );

    emit(newState);
  }

  void selectService(ServiceModel? service) async {
    if (service != null) {
      emit(state.copyWith(
        selectedService: service,
        isSectionsLoading: true,
        selectedSection: null,
        sections: [],
        sectionError: null,
        sectionSuccess: null,
      ));

      try {
        final sections = await _apiService.fetchSections(service.id);
        emit(state.copyWith(
          sections: sections,
          isSectionsLoading: false,
        ));
      } catch (e) {
        emit(state.copyWith(
          isSectionsLoading: false,
          sectionError: 'Failed to load sections',
        ));
      }
    }
    validateFields();
  }

  void selectSection(SectionModel? section) {
    if (section != null) {
      emit(state.copyWith(selectedSection: section));
    }
    validateFields();
  }

  Future<void> submitForm(BuildContext context) async {
    if (!state.isButtonEnabled || state.selectedService == null) {
      emit(state.copyWith(
          submissionError: 'Please complete all fields correctly'));
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final Map<String, dynamic> response;

      if (ticketId != null) {
        response = await _ticketService.updateTicket(
          ticketId: ticketId!,
          description: descriptionController.text.trim(),
          title: titleController.text.trim(),
          serviceId: state.selectedService!.id.toString(),
        );
      } else {
        response = await _ticketService.createTicket(
          description: descriptionController.text.trim(),
          title: titleController.text.trim(),
          serviceId: state.selectedService!.id.toString(),
            sectionId: state.selectedSection!.id.toString(),
        );
      }

      if (response['success']) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
      } else {
        emit(state.copyWith(
          isLoading: false,
          submissionError: response['message'] ?? 'Failed to process ticket',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        submissionError: 'Submission failed: ${e.toString()}',
      ));
    }
  }

  @override
  Future<void> close() {
    descriptionController.dispose();
    titleController.dispose();
    _debounceTimer?.cancel();
    return super.close();
  }
}
