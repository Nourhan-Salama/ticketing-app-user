import 'package:equatable/equatable.dart';
import 'package:final_app/models/section-model.dart';
import 'package:final_app/models/service-model.dart';
import 'package:final_app/models/ticket-model.dart';

class CreateNewState extends Equatable {
  final String? firstNameError;
  final String? lastNameError;
  final String? emailError;
  final String? descriptionError;
  final String? departmentError;
  final String? titleError;
  final String? serviceError;
  final List<SectionModel> sections;
  final SectionModel? selectedSection;
  final String? sectionError;
  final String? sectionSuccess;
  final bool isSectionsLoading;

  final TicketModel? ticketToLoad;

  final String? firstNameSuccess;
  final String? lastNameSuccess;
  final String? emailSuccess;
  final String? descriptionSuccess;
  final String? departmentSuccess;
  final String? titleSuccess;
  final String? serviceSuccess;

  final bool isButtonEnabled;
  final bool isLoading;
  final bool isSuccess;
  final String? submissionError;

  final List<ServiceModel> services;
  final ServiceModel? selectedService;

  const CreateNewState({
    this.ticketToLoad,
    this.departmentSuccess,
    this.emailSuccess,
    this.lastNameSuccess,
    this.descriptionSuccess,
    this.firstNameSuccess,
    this.titleSuccess,
    this.serviceSuccess,
    this.firstNameError,
    this.lastNameError,
    this.emailError,
    this.descriptionError,
    this.departmentError,
    this.titleError,
    this.serviceError,
    this.isButtonEnabled = false,
    this.isLoading = false,
    this.isSuccess = false,
    this.submissionError,
    this.services = const [],
    this.selectedService,
    this.sections = const [],
    this.selectedSection,
    this.sectionError,
    this.sectionSuccess,
    this.isSectionsLoading = false,
  });

  factory CreateNewState.initial() => const CreateNewState();

  CreateNewState copyWith({
    TicketModel? ticketToLoad,
    String? departmentSuccess,
    String? lastNameSuccess,
    String? descriptionSuccess,
    String? emailSuccess,
    String? firstNameSuccess,
    String? titleSuccess,
    String? serviceSuccess,
    String? firstNameError,
    String? lastNameError,
    String? emailError,
    String? descriptionError,
    String? departmentError,
    String? titleError,
    String? serviceError,
    bool? isButtonEnabled,
    bool? isLoading,
    bool? isSuccess,
    String? submissionError,
    List<ServiceModel>? services,
    ServiceModel? selectedService,
    List<SectionModel>? sections,
    SectionModel? selectedSection,
    String? sectionError,
    String? sectionSuccess,
    bool? isSectionsLoading,
  }) {
    return CreateNewState(
      ticketToLoad: ticketToLoad ?? this.ticketToLoad,
      departmentSuccess: departmentSuccess ?? this.departmentSuccess,
      descriptionSuccess: descriptionSuccess ?? this.descriptionSuccess,
      emailSuccess: emailSuccess ?? this.emailSuccess,
      lastNameSuccess: lastNameSuccess ?? this.lastNameSuccess,
      firstNameSuccess: firstNameSuccess ?? this.firstNameSuccess,
      titleSuccess: titleSuccess ?? this.titleSuccess,
      serviceSuccess: serviceSuccess ?? this.serviceSuccess,
      firstNameError: firstNameError ?? this.firstNameError,
      lastNameError: lastNameError ?? this.lastNameError,
      emailError: emailError ?? this.emailError,
      descriptionError: descriptionError ?? this.descriptionError,
      departmentError: departmentError ?? this.departmentError,
      titleError: titleError ?? this.titleError,
      serviceError: serviceError ?? this.serviceError,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      submissionError: submissionError,
      services: services ?? this.services,
      selectedService: selectedService ?? this.selectedService,
      sections: sections ?? this.sections,
      selectedSection: selectedSection ?? this.selectedSection,
      sectionError: sectionError ?? this.sectionError,
      sectionSuccess: sectionSuccess ?? this.sectionSuccess,
      isSectionsLoading: isSectionsLoading ?? this.isSectionsLoading,
    );
  }

  @override
  List<Object?> get props => [
        departmentSuccess,
        firstNameSuccess,
        lastNameSuccess,
        emailSuccess,
        descriptionSuccess,
        titleSuccess,
        serviceSuccess,
        firstNameError,
        lastNameError,
        emailError,
        descriptionError,
        departmentError,
        titleError,
        serviceError,
        isButtonEnabled,
        isLoading,
        isSuccess,
        submissionError,
        services,
        selectedService,
        ticketToLoad,
        sections,
        selectedSection,
        sectionError,
        sectionSuccess,
        isSectionsLoading,
      ];
}
