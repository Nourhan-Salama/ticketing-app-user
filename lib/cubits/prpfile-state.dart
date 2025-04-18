import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String firstName;
  final String lastName;
  final String email;
  final String? imagePath;
  final File? imageFile;
  final String? firstNameError;
  final String? lastNameError;
  final String? emailError;
  final String? errorMessage;
  final String? firstNameSuccess;
  final String? lastNameSuccess;
  final String? emailSuccess;
  final bool isLoading;
  final bool isSuccess;
  final bool isButtonEnabled;

  const ProfileLoaded({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.imagePath,
    this.imageFile,
    this.firstNameError,
    this.lastNameError,
    this.emailError,
    this.errorMessage,
    this.firstNameSuccess,
    this.lastNameSuccess,
    this.emailSuccess,
    this.isLoading = false,
    this.isSuccess = false,
    this.isButtonEnabled = false,
  });

  ProfileLoaded copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? imagePath,
    File? imageFile,
    String? firstNameError,
    String? lastNameError,
    String? emailError,
    String? errorMessage,
    String? firstNameSuccess,
    String? lastNameSuccess,
    String? emailSuccess,
    bool? isLoading,
    bool? isSuccess,
    bool? isButtonEnabled,
  }) {
    return ProfileLoaded(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      imagePath: imagePath ?? this.imagePath,
      imageFile: imageFile ?? this.imageFile,
      firstNameError: firstNameError ?? this.firstNameError,
      lastNameError: lastNameError ?? this.lastNameError,
      emailError: emailError ?? this.emailError,
      errorMessage: errorMessage ?? this.errorMessage,
      firstNameSuccess: firstNameSuccess ?? this.firstNameSuccess,
      lastNameSuccess: lastNameSuccess ?? this.lastNameSuccess,
      emailSuccess: emailSuccess ?? this.emailSuccess,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
    );
  }

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        imagePath,
        imageFile,
        firstNameError,
        lastNameError,
        emailError,
        errorMessage,
        firstNameSuccess,
        lastNameSuccess,
        emailSuccess,
        isLoading,
        isSuccess,
        isButtonEnabled,
      ];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}



// import 'dart:io';

// import 'package:equatable/equatable.dart';

// abstract class ProfileState extends Equatable {
//   const ProfileState();

//   @override
//   List<Object?> get props => [];
// }

// class ProfileInitial extends ProfileState {}

// class ProfileLoading extends ProfileState {}

// class ProfileLoaded extends ProfileState {
//   final String firstName;
//   final String lastName;
//   final String email;
//   final String? imagePath;
//   final File? imageFile;
//   final bool isFirstNameValid;
//   final bool isLastNameValid;
//   final bool isEmailValid;
//   final bool showFirstNameValidation;
//   final bool showLastNameValidation;
//   final bool showEmailValidation;
//   final bool isButtonEnabled;

//   const ProfileLoaded({
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//     this.imagePath,
//     this.imageFile,
//     this.isFirstNameValid = true,
//     this.isLastNameValid = true,
//     this.isEmailValid = true,
//     this.showFirstNameValidation = false,
//     this.showLastNameValidation = false,
//     this.showEmailValidation = false,
//     this.isButtonEnabled = false,
//   });

//   ProfileLoaded copyWith({
//     String? firstName,
//     String? lastName,
//     String? email,
//     String? imagePath,
//     File? imageFile,
//     bool? isFirstNameValid,
//     bool? isLastNameValid,
//     bool? isEmailValid,
//     bool? showFirstNameValidation,
//     bool? showLastNameValidation,
//     bool? showEmailValidation,
//     bool? isButtonEnabled,
//   }) {
//     return ProfileLoaded(
//       firstName: firstName ?? this.firstName,
//       lastName: lastName ?? this.lastName,
//       email: email ?? this.email,
//       imagePath: imagePath ?? this.imagePath,
//       imageFile: imageFile ?? this.imageFile,
//       isFirstNameValid: isFirstNameValid ?? this.isFirstNameValid,
//       isLastNameValid: isLastNameValid ?? this.isLastNameValid,
//       isEmailValid: isEmailValid ?? this.isEmailValid,
//       showFirstNameValidation:
//           showFirstNameValidation ?? this.showFirstNameValidation,
//       showLastNameValidation: showLastNameValidation ?? this.showLastNameValidation,
//       showEmailValidation: showEmailValidation ?? this.showEmailValidation,
//       isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         firstName,
//         lastName,
//         email,
//         imagePath,
//         imageFile,
//         isFirstNameValid,
//         isLastNameValid,
//         isEmailValid,
//         showFirstNameValidation,
//         showLastNameValidation,
//         showEmailValidation,
//         isButtonEnabled,
//       ];
// }

// class ProfileSuccess extends ProfileState {
//   final String message;
//   const ProfileSuccess(this.message);

//   @override
//   List<Object> get props => [message];
// }

// class ProfileError extends ProfileState {
//   final String message;
//   const ProfileError(this.message);

//   @override
//   List<Object> get props => [message];
// }




