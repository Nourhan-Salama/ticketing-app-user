
import 'dart:io';
import 'package:final_app/cubits/profile/prpfile-state.dart';
import 'package:final_app/services/service-profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService _profileService;

  ProfileCubit(this._profileService)
      : super(ProfileLoaded(
          firstName: '',
          lastName: '',
          email: '',
          imagePath: null,
          removeImage: false,
          isButtonEnabled: false,
          isLoading: false,
        )) {
    loadProfile();
  }

  void loadProfile() async {
    emit(ProfileLoading());
    try {
      final profile = await ProfileService.getProfile();
      emit(ProfileLoaded(
        firstName: profile?.firstName ?? '',
        lastName: profile?.lastName ?? '',
        email: profile?.email ?? '',
          imagePath: profile?.avatar,
        removeImage: false,
        isButtonEnabled: false,
        isLoading: false,
      ));
    } catch (e) {
      emit(ProfileError('Failed to load profile'));
    }
  }

  void updateProfileField({
    String? firstName,
    String? lastName,
    String? email,
  }) {
    if (state is! ProfileLoaded) return;
    final current = state as ProfileLoaded;

    final updated = current.copyWith(
      firstName: firstName ?? current.firstName,
      lastName: lastName ?? current.lastName,
      email: email ?? current.email,
      isButtonEnabled: true,
    );
    emit(updated);
  }

  void updateImage(File? file) {
    if (state is! ProfileLoaded) return;
    final current = state as ProfileLoaded;
    emit(current.copyWith(
      imageFile: file,
      removeImage: file == null,
      isButtonEnabled: true,
    ));
  }
  
  void removeImage() {
    if (state is! ProfileLoaded) return;
    final current = state as ProfileLoaded;
    emit(current.copyWith(
      imageFile: null,
      imagePath: null,
      removeImage: true,
      isButtonEnabled: true,
    ));
  }

  void resetSuccess() {
    if (state is ProfileSuccess) {
      // After showing success, go back to loaded state
      loadProfile();
    }
  }

  void saveProfile({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    if (state is! ProfileLoaded) return;
    var current = state as ProfileLoaded;

    emit(current.copyWith(isLoading: true));

    try {
      await ProfileService.updateProfile(
        name: '$firstName $lastName',
        email: email,
        avatar: current.removeImage ? null : current.imageFile,
        removeAvatar: current.removeImage,
      );

      // Emit success state
      emit(ProfileSuccess());
    } catch (e) {
      emit(ProfileError('Failed to update profile'));
    }
  }
} 
