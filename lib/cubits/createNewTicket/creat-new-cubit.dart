import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:final_app/Widgets/drawer.dart';
import 'package:final_app/models/ticket-model.dart';
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
      if (ticket != null) {
        initialService = services.firstWhere(
          (s) => s.id == ticket!.service.id,
          orElse: () => services.isNotEmpty ? services[0] : ServiceModel.empty(),
        );
      }
      
      emit(state.copyWith(
        services: services,
        selectedService: initialService,
      ));
      
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
      descriptionSuccess: null,
      titleSuccess: null,
      serviceSuccess: null,
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

    newState = newState.copyWith(
      isButtonEnabled: description.length >= 10 &&
          title.length >= 3 &&
          state.selectedService != null,
    );

    emit(newState);
  }

  void selectService(ServiceModel? service) {
    if (service != null) {
      emit(state.copyWith(selectedService: service));
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
// import 'dart:async';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:final_app/Widgets/drawer.dart';
// import 'package:final_app/models/ticket-model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:final_app/cubits/createNewTicket/create-new-state.dart';
// import 'package:final_app/services/ticket-service.dart';
// import 'package:final_app/models/service-model.dart';

// class CreateNewCubit extends Cubit<CreateNewState> {
//   final TextEditingController descriptionController = TextEditingController();
//   final TextEditingController titleController = TextEditingController();
//   //final TextEditingController serviceController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//   final TicketService _ticketService = TicketService();
//   Timer? _debounceTimer;

//   // Add ticket ID to track edit mode
//   int? ticketId;
//   final TicketModel? ticket;

//   CreateNewCubit({this.ticket}) : super(CreateNewState.initial()) {
//     _setupListeners();
//     _ticketService.fetchServices().then((services) {
//       emit(state.copyWith(services: services));
//     });
//     if (ticket != null) {
//       loadTicket(ticket!);
//     }
//   }

//   void _setupListeners() {
//     descriptionController.addListener(_debouncedValidation);
//     titleController.addListener(_debouncedValidation);
//     // serviceController.addListener(_debouncedValidation);
//   }

//   void loadTicket(TicketModel ticket) {
//     titleController.text = ticket.title;
//     descriptionController.text = ticket.description;
//     ticketId = ticket.id;

//     // selectService(ticket.service);
//     validateFields();
//   }

//   //   Future<void> loadServices() async {
//   //   try {
//   //     emit(state.copyWith(isLoading: true));
//   //     final services = await _ticketService.fetchServices();
//   //     emit(state.copyWith(services: services, isLoading: false));
//   //   } catch (e) {
//   //     emit(state.copyWith(
//   //       isLoading: false,
//   //       submissionError: 'Failed to load services: $e',
//   //     ));
//   //   }
//   // }

//   void _debouncedValidation() {
//     _debounceTimer?.cancel();
//     _debounceTimer = Timer(const Duration(milliseconds: 500), validateFields);
//   }

//   void validateFields() {
//     final description = descriptionController.text.trim();
//     final title = titleController.text.trim();

//     var newState = state.copyWith(
//       descriptionError: null,
//       titleError: null,
//       serviceError: null,
//       descriptionSuccess: null,
//       titleSuccess: null,
//       serviceSuccess: null,
//     );

//     if (description.isEmpty || description.length < 10) {
//       newState = newState.copyWith(descriptionError: 'At least 10 characters');
//     } else {
//       newState = newState.copyWith(descriptionSuccess: 'goodDescription'.tr());
//     }

//     if (title.isEmpty || title.length < 3) {
//       newState = newState.copyWith(titleError: 'At least 3 characters');
//     } else {
//       newState = newState.copyWith(titleSuccess: 'niceTitle'.tr());
//     }

//     if (state.selectedService == null) {
//       newState = newState.copyWith(serviceError: 'Please choose a service');
//     } else {
//       newState = newState.copyWith(serviceSuccess: 'serviceSelected'.tr());
//     }

//     newState = newState.copyWith(
//       isButtonEnabled: description.length >= 10 &&
//           title.length >= 3 &&
//           state.selectedService != null,
//     );

//     emit(newState);
//   }

//   void selectService(ServiceModel? service) {
//     if (service != null) {
//       emit(state.copyWith(selectedService: service));
//     }
//     validateFields();
//   }

//   Future<void> submitForm(BuildContext context) async {
//     if (!state.isButtonEnabled || state.selectedService == null) {
//       emit(state.copyWith(
//           submissionError: 'Please complete all fields correctly'));
//       return;
//     }

//     emit(state.copyWith(isLoading: true));

//     try {
//       final Map<String, dynamic> response;

//       if (ticketId != null) {
//         // We're updating an existing ticket
//         response = await _ticketService.updateTicket(
//           ticketId: ticketId!,
//           description: descriptionController.text.trim(),
//           title: titleController.text.trim(),
//           serviceId: state.selectedService!.id.toString(),
//         );
//       } else {
//         // We're creating a new ticket
//         response = await _ticketService.createTicket(
//           description: descriptionController.text.trim(),
//           title: titleController.text.trim(),
//           serviceId: state.selectedService!.id.toString(),
//         );
//       }

//       if (response['success']) {
//         emit(state.copyWith(isLoading: false, isSuccess: true));
//       } else {
//         emit(state.copyWith(
//           isLoading: false,
//           submissionError: response['message'] ?? 'Failed to process ticket',
//         ));
//       }
//     } catch (e) {
//       emit(state.copyWith(
//         isLoading: false,
//         submissionError: 'Submission failed: ${e.toString()}',
//       ));
//     }
//   }

//   @override
//   Future<void> close() {
//     descriptionController.dispose();
//     titleController.dispose();

//     _debounceTimer?.cancel();
//     return super.close();
//   }
// }
