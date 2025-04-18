// // profile-state.dart
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
//   final String name;
//   final String email;
//   final String? imagePath;
//   final File? imageFile;
//   final bool isNameValid;
//   final bool isEmailValid;
//   final bool isButtonEnabled;

//   const ProfileLoaded({
//     required this.name,
//     required this.email,
//     this.imagePath,
//     this.imageFile,
//     this.isNameValid = true,
//     this.isEmailValid = true,
//     this.isButtonEnabled = false,
//   });

//   ProfileLoaded copyWith({
//     String? name,
//     String? email,
//     String? imagePath,
//     File? imageFile,
//     bool? isNameValid,
//     bool? isEmailValid,
//     bool? isButtonEnabled,
//   }) {
//     return ProfileLoaded(
//       name: name ?? this.name,
//       email: email ?? this.email,
//       imagePath: imagePath ?? this.imagePath,
//       imageFile: imageFile ?? this.imageFile,
//       isNameValid: isNameValid ?? this.isNameValid,
//       isEmailValid: isEmailValid ?? this.isEmailValid,
//       isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         name,
//         email,
//         imagePath,
//         imageFile,
//         isNameValid,
//         isEmailValid,
//         isButtonEnabled,
//       ];
// }

// class ProfileError extends ProfileState {
//   final String message;
//   const ProfileError(this.message);
//   @override
//   List<Object> get props => [message];
// }

// profile-state.dart



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
  final bool isFirstNameValid;
  final bool isLastNameValid;
  final bool isEmailValid;
  final bool showFirstNameValidation;
  final bool showLastNameValidation;
  final bool showEmailValidation;
  final bool isButtonEnabled;

  const ProfileLoaded({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.imagePath,
    this.imageFile,
    this.isFirstNameValid = true,
    this.isLastNameValid = true,
    this.isEmailValid = true,
    this.showFirstNameValidation = false,
    this.showLastNameValidation = false,
    this.showEmailValidation = false,
    this.isButtonEnabled = false,
  });

  ProfileLoaded copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? imagePath,
    File? imageFile,
    bool? isFirstNameValid,
    bool? isLastNameValid,
    bool? isEmailValid,
    bool? showFirstNameValidation,
    bool? showLastNameValidation,
    bool? showEmailValidation,
    bool? isButtonEnabled,
  }) {
    return ProfileLoaded(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      imagePath: imagePath ?? this.imagePath,
      imageFile: imageFile ?? this.imageFile,
      isFirstNameValid: isFirstNameValid ?? this.isFirstNameValid,
      isLastNameValid: isLastNameValid ?? this.isLastNameValid,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      showFirstNameValidation:
          showFirstNameValidation ?? this.showFirstNameValidation,
      showLastNameValidation: showLastNameValidation ?? this.showLastNameValidation,
      showEmailValidation: showEmailValidation ?? this.showEmailValidation,
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
        isFirstNameValid,
        isLastNameValid,
        isEmailValid,
        showFirstNameValidation,
        showLastNameValidation,
        showEmailValidation,
        isButtonEnabled,
      ];
}

class ProfileSuccess extends ProfileState {
  final String message;
  const ProfileSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}




