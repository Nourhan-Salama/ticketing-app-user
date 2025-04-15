import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:final_app/cubits/prpfile-state.dart';
import 'package:final_app/services/service-profile.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService profileService;

  ProfileCubit(this.profileService) : super(ProfileLoading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final profileData = await profileService.getProfile();
      emit(ProfileLoaded(
        imagePath: profileData['avatar'] ?? '',
        firstName: profileData['firstName'] ?? profileData['name']?.split(' ').first ?? '',
        lastName: profileData['lastName'] ?? profileData['name']?.split(' ').last ?? '',
        email: profileData['email'] ?? '',
      ));
    } catch (e) {
      emit(ProfileError('Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    File? imageFile,
  }) async {
    try {
      emit(ProfileLoading());

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await profileService.uploadProfileImage(imageFile);
      }

      await profileService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        imageUrl: imageUrl,
      );

      emit(ProfileLoaded(
        imagePath: imageUrl ?? (state as ProfileLoaded).imagePath,
        firstName: firstName,
        lastName: lastName,
        email: email,
      ));
    } catch (e) {
      emit(ProfileError('Failed to update profile: ${e.toString()}'));
      rethrow;
    }
  }

  Future<void> updateProfileImage(File imageFile) async {
    try {
      emit(ProfileLoading());
      final imageUrl = await profileService.uploadProfileImage(imageFile);

      final currentState = state;
      if (currentState is ProfileLoaded) {
        emit(ProfileLoaded(
          imagePath: imageUrl,
          firstName: currentState.firstName,
          lastName: currentState.lastName,
          email: currentState.email,
        ));
      }
    } catch (e) {
      emit(ProfileError('Failed to update profile image: ${e.toString()}'));
      rethrow;
    }
  }
}



