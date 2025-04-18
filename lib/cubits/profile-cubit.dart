// import 'dart:io';
// import 'package:final_app/cubits/prpfile-state.dart';
// import 'package:final_app/services/service-profile.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class ProfileCubit extends Cubit<ProfileState> {
//   final ProfileService profileService;

//   ProfileCubit(this.profileService) : super(ProfileInitial());

//   void updateField({String? name, String? email}) {
//     if (state is! ProfileLoaded) return;

//     final current = state as ProfileLoaded;
//     final newName = name ?? current.name;
//     final newEmail = email ?? current.email;

//     final isNameValid = newName.trim().length >= 2;
//     final isEmailValid = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
//         .hasMatch(newEmail.trim());

//     emit(current.copyWith(
//       name: newName,
//       email: newEmail,
//       isNameValid: isNameValid,
//       isEmailValid: isEmailValid,
//       isButtonEnabled: isNameValid && isEmailValid,
//     ));
//   }

//   void updateImage(File? imageFile) {
//     if (state is! ProfileLoaded) return;
    
//     final current = state as ProfileLoaded;
//     emit(current.copyWith(
//       imageFile: imageFile,
//       isButtonEnabled: true, // Enable save button when image changes
//     ));
//   }

//   Future<void> saveProfile() async {
//     if (state is! ProfileLoaded) return;
//     final current = state as ProfileLoaded;

//     emit(ProfileLoading());
//     try {
//       // Save to API
//       await profileService.updateProfile(
//         name: current.name,
//         email: current.email,
//         avatar: current.imageFile,
//       );

//       // Save to local storage
//       await profileService.saveUserData(
//         name: current.name,
//         email: current.email,
//         imagePath: current.imageFile?.path ?? current.imagePath,
//       );

//       // Reload profile to get any server-generated changes
//       await loadProfile();

//       emit(ProfileLoaded(
//         name: current.name,
//         email: current.email,
//         imagePath: current.imageFile?.path ?? current.imagePath,
//         isButtonEnabled: false, // Disable save button after successful save
//       ));
//     } catch (e) {
//       emit(ProfileError(e.toString()));
//       emit(current); // Revert to previous state on error
//     }
//   }

//   Future<void> loadProfile() async {
//     emit(ProfileLoading());
//     try {
//       final profileData = await profileService.getProfile();
//       final name = profileData['user']['name'] ?? "User";
//       final email = profileData['user']['email'] ?? "user@example.com";
//       final imagePath = profileData['user']['avatar'] ?? '';

//       await profileService.saveUserData(
//         name: name,
//         email: email,
//         imagePath: imagePath,
//       );

//       emit(ProfileLoaded(
//         name: name,
//         email: email,
//         imagePath: imagePath,
//       ));
//     } catch (e) {
//       try {
//         final localData = await profileService.loadUserData();
//         emit(ProfileLoaded(
//           name: localData['name'] ?? "User",
//           email: localData['email'] ?? "user@example.com",
//           imagePath: localData['image_path'] ?? '',
//         ));
//       } catch (e) {
//         emit(ProfileError("Failed to load profile"));
//       }
//     }
//   }

//   Future<void> clearProfile() async {
//     await profileService.clearUserData();
//     emit(ProfileInitial());
//   }
// }

import 'dart:io';
import 'package:final_app/cubits/prpfile-state.dart';
import 'package:final_app/services/service-profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService profileService;

  ProfileCubit(this.profileService) : super(ProfileInitial());

  void updateField({String? first, String? last, String? mail}) {
    if (state is! ProfileLoaded) return;

    final current = state as ProfileLoaded;
    final newFirst = first ?? current.firstName;
    final newLast = last ?? current.lastName;
    final newMail = mail ?? current.email;

    final isFirstValid = newFirst.trim().length >= 2;
    final isLastValid = newLast.trim().length >= 2;
    final isEmailValid = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(newMail.trim());

    final isAnyChanged = newFirst != current.firstName ||
        newLast != current.lastName ||
        newMail != current.email ||
        current.imageFile != null;

    final isFormValid =
        isFirstValid && isLastValid && isEmailValid && isAnyChanged;

    emit(current.copyWith(
      firstName: newFirst,
      lastName: newLast,
      email: newMail,
      isFirstNameValid: isFirstValid,
      isLastNameValid: isLastValid,
      isEmailValid: isEmailValid,
      showFirstNameValidation: newFirst.isNotEmpty,
      showLastNameValidation: newLast.isNotEmpty,
      showEmailValidation: newMail.isNotEmpty,
      isButtonEnabled: isFormValid,
    ));
  }

  void updateImage(File? image) {
    if (state is! ProfileLoaded) return;
    final current = state as ProfileLoaded;
    emit(current.copyWith(
      imageFile: image,
      isButtonEnabled: _checkFormValidity(current, image: image),
    ));
  }

  bool _checkFormValidity(ProfileLoaded state, {File? image}) {
    final isFirstValid = state.firstName.trim().length >= 2;
    final isLastValid = state.lastName.trim().length >= 2;
    final isEmailValid = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(state.email.trim());

    final hasChanges = image != null ||
        state.firstName != "Current" ||
        state.lastName != "User" ||
        state.email != "user@example.com";

    return isFirstValid && isLastValid && isEmailValid && hasChanges;
  }

  Future<void> submitProfile() async {
    if (state is! ProfileLoaded) return;

    final current = state as ProfileLoaded;
    emit(ProfileLoading());

    try {
      await profileService.updateProfile(
        firstName: current.firstName,
        lastName: current.lastName,
        email: current.email,
        avatar: current.imageFile,
      );

      final updatedData = await profileService.getProfile();

      final updatedFirstName = updatedData['firstName'] ?? current.firstName;
      final updatedLastName = updatedData['lastName'] ?? current.lastName;
      final updatedEmail = updatedData['email'] ?? current.email;
      final updatedImage = updatedData['imageUrl'] ?? current.imagePath;
//save the data local
      await profileService.saveUserData(
        firstName: current.firstName,
        lastName: current.lastName,
        email: updatedEmail,
        imagePath: updatedImage,
      );

      emit(ProfileLoaded(
        firstName: updatedFirstName,
        lastName: updatedLastName,
        email: updatedEmail,
        imagePath: updatedImage,
        isButtonEnabled: false,
      ));

      emit(ProfileSuccess("Profile updated successfully"));
    } catch (e) {
      emit(ProfileError(e.toString()));
      emit(current); // Revert to previous state on error
    }
  }

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final profileData = await profileService.getProfile();

      final firstName = profileData['firstName'] ?? "Current";
      final lastName = profileData['lastName'] ?? "User";
      final email = profileData['email'] ?? "user@example.com";
      final imagePath = profileData['imageUrl'] ?? '';

  //   save data in secure storage 
      await profileService.saveUserData(
        firstName: firstName,
        lastName: lastName,
        email: email,
        imagePath: imagePath,
      );

      emit(ProfileLoaded(
        firstName: firstName,
        lastName: lastName,
        email: email,
        imagePath: imagePath,
      ));
    } catch (e) {
    // try loading user data from local
      try {
        final localData = await profileService.loadUserData();
        emit(ProfileLoaded(
          firstName: localData['first_name'] ?? "Current",
          lastName: localData['last_name'] ?? "User",
          email: localData['email'] ?? "user@example.com",
          imagePath: localData['image_path'] ?? '',
        ));
      } catch (e) {
        emit(ProfileError("Failed to load profile: $e"));
      }
    }
  }

// to delete user data from local after logout
  Future<void> clearLocalProfile() async {
    await profileService.clearUserData();
    emit(ProfileInitial());
  }
}











