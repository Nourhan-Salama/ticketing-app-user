import 'dart:convert';

import 'package:final_app/cubits/changePassword/change-pass-state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  ChangePasswordCubit() : super(ChangePasswordInitial()) {
    passwordController.addListener(validatePasswords);
    confirmPasswordController.addListener(validatePasswords);
  }

  void validatePasswords() {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    String? passwordError;
    String? confirmPasswordError;
    bool isValid = true;

    // Validate new password
    if (password.isEmpty) {
      passwordError = 'password_empty'.tr();
      isValid = false;
    } else if (password.length < 8) {
      passwordError = 'password_short'.tr();
      isValid = false;
    }

    // Validate confirm password
    if (confirmPassword.isEmpty) {
      confirmPasswordError = 'confirm_password_empty'.tr();
      isValid = false;
    } else if (password != confirmPassword) {
      confirmPasswordError = 'passwords_do_not_match'.tr();
      isValid = false;
    }

    emit(ChangePasswordValid(isValid, 
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError));
  }

  void clearFields() {
    passwordController.clear();
    confirmPasswordController.clear();
    emit(ChangePasswordInitial()); 
  }

  Future<void> resetPassword({
    required String handle,
    required String verificationCode,
  }) async {
    if (state is! ChangePasswordValid || !(state as ChangePasswordValid).isEnabled) {
      return;
    }

    emit(ChangePasswordLoading());

    final url = Uri.parse('https://graduation.arabic4u.org/auth/password/reset_password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'handle': handle,
          'code': verificationCode,
          'password': passwordController.text,
          'password_confirmation': confirmPasswordController.text,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        clearFields();
        emit(ChangePasswordSuccess());
      } else {
        String errorMessage = responseData['message'] ?? 'reset_password_failed'.tr();
        
        // Handle specific errors from API
        if (responseData.containsKey('errors')) {
          if (responseData['errors']['password'] != null) {
            errorMessage = responseData['errors']['password'][0];
          } else if (responseData['errors']['code'] != null) {
            errorMessage = responseData['errors']['code'][0];
          }
        }
        
        emit(ChangePasswordFailure(errorMessage));
      }
    } catch (e) {
      emit(ChangePasswordFailure('connection_error'.tr()));
    }
  }

  @override
  Future<void> close() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }
}

