

abstract class ChangePasswordState {}

class ChangePasswordInitial extends ChangePasswordState {}

class ChangePasswordValid extends ChangePasswordState {
  final bool isEnabled;
  final String? passwordError;
  final String? confirmPasswordError;
  
  ChangePasswordValid(
    this.isEnabled, {
    this.passwordError,
    this.confirmPasswordError,
  });
}

class ChangePasswordLoading extends ChangePasswordState {}

class ChangePasswordSuccess extends ChangePasswordState {}

class ChangePasswordFailure extends ChangePasswordState {
  final String message;
  ChangePasswordFailure(this.message);
}
