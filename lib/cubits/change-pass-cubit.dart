import 'dart:convert';
import 'package:final_app/cubits/change-pass-state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  ChangePasswordCubit() : super(ChangePasswordInitial()) {
    passwordController.addListener(validatePasswords);
    confirmPasswordController.addListener(validatePasswords);
  }

  /// ✅ التحقق من صحة كلمة المرور والتأكيد
  void validatePasswords() {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    bool isValid = password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        password == confirmPassword &&
        password.length >= 8;

    emit(ChangePasswordValid(isValid));
  }

  /// ✅ حذف البيانات بعد النجاح
  void clearFields() {
    passwordController.clear();
    confirmPasswordController.clear();
    emit(ChangePasswordInitial()); // يرجع الحالة للبداية
  }

  /// ✅ إرسال الطلب لتغيير كلمة المرور
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
        clearFields(); // 🟢 حذف البيانات بعد النجاح
        emit(ChangePasswordSuccess());
      } else {
        emit(ChangePasswordFailure(responseData['message']));
      }
    } catch (e) {
      emit(ChangePasswordFailure('Something went wrong!'));
    }
  }

  @override
  Future<void> close() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }
}

