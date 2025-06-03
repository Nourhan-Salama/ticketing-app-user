
import 'package:equatable/equatable.dart';

class SignUpState extends Equatable {
  final String? firstNameError;
  final String? lastNameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? errorMessage;
  final String? firstNameSuccess;
  final String? lastNameSuccess;
  final String? emailSuccess;
  final String? passwordSuccess;
  final String? confirmPasswordSuccess;
  final bool isButtonEnabled;
  final bool isLoading;
  final bool isSuccess;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final String? email;

  const SignUpState({
    this.email,
    this.firstNameError,
    this.lastNameError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.errorMessage,
    this.firstNameSuccess,
    this.lastNameSuccess,
    this.emailSuccess,
    this.passwordSuccess,
    this.confirmPasswordSuccess,
    this.isButtonEnabled = false,
    this.isLoading = false,
    this.isSuccess = false,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
  });

  factory SignUpState.initial() => const SignUpState();

  SignUpState copyWith({
    String?email,
    String? firstNameError,
    String? lastNameError,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? errorMessage,
    String? firstNameSuccess,
    String? lastNameSuccess,
    String? emailSuccess,
    String? passwordSuccess,
    String? confirmPasswordSuccess,
    bool? isButtonEnabled,
    bool? isLoading,
    bool? isSuccess,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
  }) {
    return SignUpState(
      email: email ?? this.email,
      firstNameError: firstNameError,
      lastNameError: lastNameError,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      errorMessage: errorMessage,
      firstNameSuccess: firstNameSuccess,
      lastNameSuccess: lastNameSuccess,
      emailSuccess: emailSuccess,
      passwordSuccess: passwordSuccess,
      confirmPasswordSuccess: confirmPasswordSuccess,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
    );
  }

  @override
  List<Object?> get props => [
        firstNameError, lastNameError, emailError, passwordError, confirmPasswordError,
        errorMessage, firstNameSuccess, lastNameSuccess, emailSuccess, passwordSuccess,
        confirmPasswordSuccess, isButtonEnabled, isLoading, isSuccess, obscurePassword, obscureConfirmPassword,
      ];
}




