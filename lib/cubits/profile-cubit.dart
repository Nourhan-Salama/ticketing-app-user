import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_app/cubits/prpfile-state.dart';
import 'package:final_app/services/service-profile.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService profileService;
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;

  File? selectedImage;

  ProfileCubit(this.profileService) : super(ProfileInitial()) {
    _initializeControllers();
    loadProfile();
  }

  void _initializeControllers() {
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();

    firstNameController.addListener(validateFields);
    lastNameController.addListener(validateFields);
    emailController.addListener(validateFields);
  }

  void validateFields() {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();

    String? firstNameError, lastNameError, emailError;
    String? firstNameSuccess, lastNameSuccess, emailSuccess;

    if (firstName.isEmpty) {
      firstNameError = 'First name is required';
    } else if (firstName.length < 2) {
      firstNameError = 'First name is too short';
    } else {
      firstNameSuccess = "Looks good!";
    }

    if (lastName.isEmpty) {
      lastNameError = 'Last name is required';
    } else if (lastName.length < 2) {
      lastNameError = 'Last name is too short';
    } else {
      lastNameSuccess = "Looks good!";
    }

    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (email.isEmpty) {
      emailError = 'Email cannot be empty';
    } else if (!emailRegex.hasMatch(email)) {
      emailError = 'Invalid Email';
    } else {
      emailSuccess = "Valid Email!";
    }

    final isButtonEnabled = firstNameError == null && lastNameError == null && emailError == null;

    emit(ProfileLoaded(
      firstName: firstName,
      lastName: lastName,
      email: email,
      imageFile: selectedImage,
      imagePath: selectedImage?.path,
      firstNameError: firstNameError,
      lastNameError: lastNameError,
      emailError: emailError,
      firstNameSuccess: firstNameSuccess,
      lastNameSuccess: lastNameSuccess,
      emailSuccess: emailSuccess,
      isButtonEnabled: isButtonEnabled,
    ));
  }

  Future<void> updateImage(File? imageFile) async {
    selectedImage = imageFile;
    validateFields();
  }

  Future<void> saveProfile() async {
    if (state is! ProfileLoaded || !(state as ProfileLoaded).isButtonEnabled) return;

    emit((state as ProfileLoaded).copyWith(isSaving: true));

    try {
      // Update profile on server
      await profileService.updateProfile(
        firstName: (state as ProfileLoaded).firstName,
        lastName: (state as ProfileLoaded).lastName,
        email: (state as ProfileLoaded).email,
        avatar: (state as ProfileLoaded).imageFile,
      );

      // Save data locally
      await profileService.saveUserData(
        firstName: (state as ProfileLoaded).firstName,
        lastName: (state as ProfileLoaded).lastName,
        email: (state as ProfileLoaded).email,
        imagePath: (state as ProfileLoaded).imageFile?.path,
      );

      emit((state as ProfileLoaded).copyWith(
        isSuccess: true,
        isButtonEnabled: false,
        isSaving: false,
      ));
    } catch (e) {
      emit((state as ProfileLoaded).copyWith(
        errorMessage: e.toString(),
        isSuccess: false,
        isSaving: false,
      ));
    }
  }

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final profileData = await profileService.getProfile();
      final fullName = profileData['user']['name'] ?? "User";
      final email = profileData['user']['email'] ?? "user@example.com";
      final imagePath = profileData['user']['avatar'] ?? '';

      final nameParts = fullName.split(" ");
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : '';

      // Update controllers without triggering listeners
      firstNameController.removeListener(validateFields);
      lastNameController.removeListener(validateFields);
      emailController.removeListener(validateFields);

      firstNameController.text = firstName;
      lastNameController.text = lastName;
      emailController.text = email;

      firstNameController.addListener(validateFields);
      lastNameController.addListener(validateFields);
      emailController.addListener(validateFields);

      emit(ProfileLoaded(
        firstName: firstName,
        lastName: lastName,
        email: email,
        imagePath: imagePath,
      ));
    } catch (e) {
      try {
        final localData = await profileService.loadUserData();
        final fullName = '${localData['firstName'] ?? ''} ${localData['lastName'] ?? ''}'.trim();
        final email = localData['email'] ?? '';
        final imagePath = localData['imagePath'] ?? '';

        // Update controllers without triggering listeners
        firstNameController.removeListener(validateFields);
        lastNameController.removeListener(validateFields);
        emailController.removeListener(validateFields);

        firstNameController.text = localData['firstName'] ?? '';
        lastNameController.text = localData['lastName'] ?? '';
        emailController.text = email;

        firstNameController.addListener(validateFields);
        lastNameController.addListener(validateFields);
        emailController.addListener(validateFields);

        emit(ProfileLoaded(
          firstName: localData['firstName'] ?? '',
          lastName: localData['lastName'] ?? '',
          email: email,
          imagePath: imagePath,
        ));
      } catch (e) {
        emit(ProfileError('Failed to load profile: $e'));
      }
    }
  }

  @override
  Future<void> close() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    return super.close();
  }
}
