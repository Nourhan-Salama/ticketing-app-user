import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_app/cubits/prpfile-state.dart';
import 'package:final_app/services/service-profile.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService profileService;

  ProfileCubit(this.profileService) : super(ProfileInitial()) {
    firstNameController.addListener(validateFields);
    lastNameController.addListener(validateFields);
    emailController.addListener(validateFields);
    loadProfile();
  }

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  File? selectedImage;

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

    final isButtonEnabled = firstNameError == null && 
                          lastNameError == null && 
                          emailError == null;

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
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(
        imageFile: imageFile,
        imagePath: imageFile?.path,
      ));
    }
  }

  Future<void> saveProfile() async {
    if (state is! ProfileLoaded || !(state as ProfileLoaded).isButtonEnabled) return;

    emit((state as ProfileLoaded).copyWith(isLoading: true));

    try {
      await profileService.updateProfile(
        firstName: (state as ProfileLoaded).firstName,
        lastName: (state as ProfileLoaded).lastName,
        email: (state as ProfileLoaded).email,
        avatar: (state as ProfileLoaded).imageFile,
      );

      await profileService.saveUserData(
        firstName: (state as ProfileLoaded).firstName,
        lastName: (state as ProfileLoaded).lastName,
        email: (state as ProfileLoaded).email,
        imagePath: (state as ProfileLoaded).imageFile?.path ?? 
                 (state as ProfileLoaded).imagePath,
      );

      emit((state as ProfileLoaded).copyWith(
        isSuccess: true,
        isLoading: false,
        isButtonEnabled: false,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
      await Future.delayed(const Duration(milliseconds: 200));
      emit((state as ProfileLoaded).copyWith(isLoading: false));
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

      firstNameController.text = firstName;
      lastNameController.text = lastName;
      emailController.text = email;

      emit(ProfileLoaded(
        firstName: firstName,
        lastName: lastName,
        email: email,
        imagePath: imagePath,
      ));
    } catch (e) {
      try {
        final localData = await profileService.loadUserData();
        final fullName = localData['name'] ?? '';
        final nameParts = fullName.split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        final email = localData['email'] ?? '';
        final imagePath = localData['image_path'] ?? '';

        firstNameController.text = firstName;
        lastNameController.text = lastName;
        emailController.text = email;

        emit(ProfileLoaded(
          firstName: firstName,
          lastName: lastName,
          email: email,
          imagePath: imagePath,
        ));
      } catch (e) {
        emit(ProfileLoaded(
          firstName: '',
          lastName: '',
          email: '',
          imagePath: '',
        ));
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


// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:final_app/cubits/prpfile-state.dart';
// import 'package:final_app/services/service-profile.dart';

// class ProfileCubit extends Cubit<ProfileState> {
//   final ProfileService profileService;

//   ProfileCubit(this.profileService) : super(ProfileInitial()) {
//    // loadProfile();
//    //1
//     // Add listeners to all controllers
//     firstNameController.addListener(validateFields);
//     lastNameController.addListener(validateFields);
//     emailController.addListener(validateFields);
//   }

//   // 2
//      final TextEditingController firstNameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
// //3
//    void validateFields() {
//     final firstName = firstNameController.text.trim();
//     final lastName = lastNameController.text.trim();
//     final email = emailController.text.trim();
   

//     String? firstNameError, lastNameError, emailError;
//     String? firstNameSuccess, lastNameSuccess, emailSuccess;

//     if (firstName.isEmpty) {
//       firstNameError = 'First name is required';
//     } else if (firstName.length < 2) {
//       firstNameError = 'First name is too short';
//     } else {
//       firstNameSuccess = "Looks good!";
//     }

//     if (lastName.isEmpty) {
//       lastNameError = 'Last name is required';
//     } else if (lastName.length < 2) {
//       lastNameError = 'Last name is too short';
//     } else {
//       lastNameSuccess = "Looks good!";
//     }

//     final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
//     if (email.isEmpty) {
//       emailError = 'Email cannot be empty';
//     } else if (!emailRegex.hasMatch(email)) {
//       emailError = 'Invalid Email';
//     } else {
//       emailSuccess = "Valid Email!";
//     }

//     final isButtonEnabled = firstName.isNotEmpty &&
//         lastName.isNotEmpty &&
//         email.isNotEmpty &&

//         firstNameError == null &&
//         lastNameError == null &&
//         emailError == null ;
       

//     emit(state.copyWith(
//       firstNameError: firstNameError,
//       lastNameError: lastNameError,
//       emailError: emailError,
//       firstNameSuccess: firstNameSuccess,
//       lastNameSuccess: lastNameSuccess,
//       emailSuccess: emailSuccess,
//       isButtonEnabled: isButtonEnabled,
//       errorMessage: null,
//       email: email, 
//     ));
//   }
// //4
//   Future<void> submitForm(BuildContext context) async {
//     validateFields();

//     if (!state.isButtonEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please fill all fields correctly'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     emit(state.copyWith(
//       isLoading: true,
//       errorMessage: null,
//     ));
//   void updateField({String? name, String? email}) {
//     if (state is! ProfileLoaded) return;

//     final current = state as ProfileLoaded;

//     final updatedName = name ?? current.name;
//     final updatedEmail = email ?? current.email;

//     final isNameValid = updatedName.trim().length >= 2;
//     final isEmailValid = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
//         .hasMatch(updatedEmail.trim());

//     emit(current.copyWith(
//       name: updatedName,
//       email: updatedEmail,
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
//       imagePath: '', 
//       isButtonEnabled: current.isNameValid && current.isEmailValid,
//     ));
//   }

//   Future<void> saveProfile() async {
//     if (state is! ProfileLoaded) return;
//     final current = state as ProfileLoaded;

//     emit(ProfileLoading());

//     try {
     
//       await profileService.updateProfile(
//         firstName: current.,
//         email: current.email,
//         avatar: current.imageFile,
//       );

    
//       await profileService.saveUserData(
//         name: current.name,
//         email: current.email,
//         imagePath: current.imageFile?.path ?? current.imagePath,
//       );

     
//       emit(ProfileLoaded(
//         name: current.name,
//         email: current.email,
//         imagePath: current.imageFile?.path ?? current.imagePath,
//         isNameValid: true,
//         isEmailValid: true,
//         isButtonEnabled: false,
//       ));
//     } catch (e) {
//       emit(ProfileError(e.toString()));
//       await Future.delayed(Duration(milliseconds: 100));
//       emit(current); 
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
//         isNameValid: true,
//         isEmailValid: true,
//         isButtonEnabled: false,
//       ));
//     } catch (apiError) {
//       try {
      
//         final localData = await profileService.loadUserData();

//         emit(ProfileLoaded(
//           name: localData['name'] ?? "User",
//           email: localData['email'] ?? "user@example.com",
//           imagePath: localData['image_path'] ?? '',
//           isNameValid: true,
//           isEmailValid: true,
//           isButtonEnabled: false,
//         ));
//       } catch (localError) {
      
//         emit(ProfileError("Failed to load profile"));

//         await Future.delayed(Duration(milliseconds: 100));
//         emit(ProfileLoaded(
//           name: "User",
//           email: "user@example.com",
//           imagePath: '',
//           isNameValid: false,
//           isEmailValid: false,
//           isButtonEnabled: false,
//         ));
//       }
//     }
//   }

//   Future<void> clearProfile() async {
//     await profileService.clearUserData();
//     emit(ProfileInitial());
//   }
// }




// import 'dart:io';
// import 'package:final_app/cubits/prpfile-state.dart';
// import 'package:final_app/services/service-profile.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class ProfileCubit extends Cubit<ProfileState> {
//   final ProfileService profileService;

//   ProfileCubit(this.profileService) : super(ProfileInitial());

//   void updateField({String? first, String? last, String? mail}) {
//     if (state is! ProfileLoaded) return;

//     final current = state as ProfileLoaded;
//     final newFirst = first ?? current.firstName;
//     final newLast = last ?? current.lastName;
//     final newMail = mail ?? current.email;

//     final isFirstValid = newFirst.trim().length >= 2;
//     final isLastValid = newLast.trim().length >= 2;
//     final isEmailValid = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
//         .hasMatch(newMail.trim());

//     final isAnyChanged = newFirst != current.firstName ||
//         newLast != current.lastName ||
//         newMail != current.email ||
//         current.imageFile != null;

//     final isFormValid =
//         isFirstValid && isLastValid && isEmailValid && isAnyChanged;

//     emit(current.copyWith(
//       firstName: newFirst,
//       lastName: newLast,
//       email: newMail,
//       isFirstNameValid: isFirstValid,
//       isLastNameValid: isLastValid,
//       isEmailValid: isEmailValid,
//       showFirstNameValidation: newFirst.isNotEmpty,
//       showLastNameValidation: newLast.isNotEmpty,
//       showEmailValidation: newMail.isNotEmpty,
//       isButtonEnabled: isFormValid,
//     ));
//   }

//   void updateImage(File? image) {
//     if (state is! ProfileLoaded) return;
//     final current = state as ProfileLoaded;
//     emit(current.copyWith(
//       imageFile: image,
//       isButtonEnabled: _checkFormValidity(current, image: image),
//     ));
//   }

//   bool _checkFormValidity(ProfileLoaded state, {File? image}) {
//     final isFirstValid = state.firstName.trim().length >= 2;
//     final isLastValid = state.lastName.trim().length >= 2;
//     final isEmailValid = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
//         .hasMatch(state.email.trim());

//     final hasChanges = image != null ||
//         state.firstName != "Current" ||
//         state.lastName != "User" ||
//         state.email != "user@example.com";

//     return isFirstValid && isLastValid && isEmailValid && hasChanges;
//   }

//   Future<void> submitProfile() async {
//     if (state is! ProfileLoaded) return;

//     final current = state as ProfileLoaded;
//     emit(ProfileLoading());

//     try {
//       await profileService.updateProfile(
//         firstName: current.firstName,
//         lastName: current.lastName,
//         email: current.email,
//         avatar: current.imageFile,
//       );

//       final updatedData = await profileService.getProfile();

//       final updatedFirstName = updatedData['firstName'] ?? current.firstName;
//       final updatedLastName = updatedData['lastName'] ?? current.lastName;
//       final updatedEmail = updatedData['email'] ?? current.email;
//       final updatedImage = updatedData['imageUrl'] ?? current.imagePath;
// //save the data local
//       await profileService.saveUserData(
//         name: u,
//         email: updatedEmail,
//         imagePath: updatedImage,
//       );

//       emit(ProfileLoaded(
//         firstName: updatedFirstName,
//         lastName: updatedLastName,
//         email: updatedEmail,
//         imagePath: updatedImage,
//         isButtonEnabled: false,
//       ));

//       emit(ProfileSuccess("Profile updated successfully"));
//     } catch (e) {
//       emit(ProfileError(e.toString()));
//       emit(current); // Revert to previous state on error
//     }
//   }

//   Future<void> loadProfile() async {
//     emit(ProfileLoading());
//     try {
//       final profileData = await profileService.getProfile();

//       final firstName = profileData['firstName'] ?? "Current";
//       final lastName = profileData['lastName'] ?? "User";
//       final email = profileData['email'] ?? "user@example.com";
//       final imagePath = profileData['imageUrl'] ?? '';

//   //   save data in secure storage 
//       await profileService.saveUserData(
//         firstName: firstName,
//         lastName: lastName,
//         email: email,
//         imagePath: imagePath,
//       );

//       emit(ProfileLoaded(
//         firstName: firstName,
//         lastName: lastName,
//         email: email,
//         imagePath: imagePath,
//       ));
//     } catch (e) {
//     // try loading user data from local
//       try {
//         final localData = await profileService.loadUserData();
//         emit(ProfileLoaded(
//           firstName: localData['first_name'] ?? "Current",
//           lastName: localData['last_name'] ?? "User",
//           email: localData['email'] ?? "user@example.com",
//           imagePath: localData['image_path'] ?? '',
//         ));
//       } catch (e) {
//         emit(ProfileError("Failed to load profile: $e"));
//       }
//     }
//   }

// // to delete user data from local after logout
//   Future<void> clearLocalProfile() async {
//     await profileService.clearUserData();
//     emit(ProfileInitial());
//   }
// }











