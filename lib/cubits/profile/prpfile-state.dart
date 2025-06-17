import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProfileLoaded extends ProfileState {
  final String firstName;
  final String lastName;
  final String email;
  final String? userId;
  final String? imagePath;
   final String? originalImagePath; 
  final File? imageFile;
  final bool removeImage;
  final bool isButtonEnabled;
  final bool isLoading;
  final bool isSuccess;

  ProfileLoaded({
    this.userId,
    required this.firstName,
      this.originalImagePath,
    required this.lastName,
    required this.email,
    this.imagePath,
    this.imageFile,
    required this.removeImage,
    required this.isButtonEnabled,
    required this.isLoading,
    this.isSuccess = false,
  });

  ProfileLoaded copyWith({
    String? userId, // allow userId to be null or unchanged
    String? firstName,
    String? lastName,
    String? email,
    String? imagePath,
    
    File? imageFile,
    bool? removeImage,
    bool? isButtonEnabled,
    bool? isLoading,
    bool? isSuccess,
  }) {
    return ProfileLoaded(
     userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      imagePath: imagePath ?? this.imagePath,
      imageFile: imageFile, // allow override with null explicitly
      removeImage: removeImage ?? this.removeImage,
        originalImagePath: originalImagePath ?? this.originalImagePath,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
    userId,
        firstName,
        lastName,
        email,
        imagePath,
        imageFile,
           originalImagePath,
        removeImage,
        isButtonEnabled,
        isLoading,
        isSuccess,
      ];
}
class ProfileSuccess extends ProfileState {} 