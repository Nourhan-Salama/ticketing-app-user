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
  final bool isSuccess;
  final bool isButtonEnabled;
  final bool isSaving;

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
    this.isSuccess = false,
    this.isButtonEnabled = false,
    this.isSaving = false,
  });

  String get fullName => '$firstName $lastName'.trim();

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
    bool? isSuccess,
    bool? isButtonEnabled,
    bool? isSaving,
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
      isSuccess: isSuccess ?? this.isSuccess,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
      isSaving: isSaving ?? this.isSaving,
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
        isSuccess,
        isButtonEnabled,
        isSaving,
      ];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}

