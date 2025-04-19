import 'package:equatable/equatable.dart';

class CreateNewState extends Equatable {
  final String? firstNameError;
  final String? lastNameError;
  final String? emailError;
  final String? descriptionError;
  final String? departmentError;

  final String? firstNameSuccess;
  final String? lastNameSuccess;
  final String? emailSuccess;
  final String? descriptionSuccess;
  final String? departmentSuccess;

  final bool isButtonEnabled;
  final bool isLoading;
  final bool isSuccess;
  final String? submissionError;

  const CreateNewState({
    this.departmentSuccess,
    this.emailSuccess,
    this.lastNameSuccess,
    this.descriptionSuccess,
    this.firstNameSuccess,
    this.firstNameError,
    this.lastNameError,
    this.emailError,
    this.descriptionError,
    this.departmentError,
    this.isButtonEnabled = false,
    this.isLoading = false,
    this.isSuccess = false,
    this.submissionError,
  });

  factory CreateNewState.initial() => const CreateNewState();

  CreateNewState copyWith({
    String? departmentSuccess,
    String? lastNameSuccess,
    String? descriptionSuccess,
    String? emailSuccess,
    String? firstNameSuccess,
    String? firstNameError,
    String? lastNameError,
    String? emailError,
    String? descriptionError,
    String? departmentError,
    bool? isButtonEnabled,
    bool? isLoading,
    bool? isSuccess,
    String? submissionError,
  }) {
    return CreateNewState(
      departmentSuccess: departmentSuccess?? this.departmentSuccess,
      descriptionSuccess: descriptionSuccess ?? this.descriptionSuccess,
      emailSuccess: emailSuccess ?? this.emailSuccess,
      lastNameSuccess: lastNameSuccess ?? this.lastNameSuccess,
      firstNameSuccess: firstNameSuccess ?? this.firstNameSuccess,
      firstNameError: firstNameError ?? this.firstNameError,
      lastNameError: lastNameError ?? this.lastNameError,
      emailError: emailError ?? this.emailError,
      descriptionError: descriptionError ?? this.descriptionError,
      departmentError: departmentError ?? this.departmentError,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      submissionError: submissionError,
    );
  }

  @override
  List<Object?> get props => [
    departmentSuccess,
        firstNameSuccess,
        lastNameSuccess,
        emailSuccess,
        descriptionSuccess,
        firstNameError,
        lastNameError,
        emailError,
        descriptionError,
        departmentError,
        isButtonEnabled,
        isLoading,
        isSuccess,
        submissionError,
      ];
}
