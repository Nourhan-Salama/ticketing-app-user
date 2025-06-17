
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:final_app/cubits/login/login-state.dart';
import 'package:final_app/services/login-service.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthApi authApi;
  final FlutterSecureStorage secureStorage;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginCubit({
    required this.authApi,
    FlutterSecureStorage? storage,
  })  : secureStorage = storage ?? const FlutterSecureStorage(),
        super(LoginState.initial()) {
    _loadRememberedCredentials();
    emailController.addListener(validateFields);
    passwordController.addListener(validateFields);
  }

  Future<void> _loadRememberedCredentials() async {
    try {
      final rememberedEmail = await secureStorage.read(key: 'remembered_email');
      final rememberedPassword = await secureStorage.read(key: 'remembered_password');
      final rememberMe = (await secureStorage.read(key: 'remember_me')) == 'true';

      if (rememberedEmail != null && rememberedPassword != null && rememberMe) {
        emailController.text = rememberedEmail;
        passwordController.text = rememberedPassword;
        emit(state.copyWith(
          rememberMe: true,
          isButtonEnabled: true,
        ));
      }
    } catch (e) {
      print('Error loading remembered credentials: $e');
    }
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void toggleRememberMe(bool value) {
    emit(state.copyWith(rememberMe: value));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  void validateFields() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    String? emailError, passwordError;
    bool isButtonEnabled = false;

    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

    if (email.isEmpty) {
      emailError = 'emailEmpty'.tr();
    }
  
    if (password.isEmpty) {
      passwordError = "passwordEmpty".tr();
    }
   

    isButtonEnabled = emailError == null &&
        passwordError == null &&
        email.isNotEmpty &&
        password.isNotEmpty;

    emit(state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
      isButtonEnabled: isButtonEnabled,
    ));
  }

  Future<void> login() async {
    if (state.isLoading) return;

    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    ));

    try {
      final response = await authApi.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response['code'] == 200) {
        await _handleSuccessfulLogin(response);
        emit(state.copyWith(
          isLoading: false,
          isSuccess: true,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: response['message'],
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'loginFailed'.tr(),
      ));
    }
  }

  Future<void> _handleSuccessfulLogin(Map<String, dynamic> response) async {
    if (state.rememberMe) {
      await secureStorage.write(
        key: 'remembered_email',
        value: emailController.text.trim(),
      );
      await secureStorage.write(
        key: 'remembered_password',
        value: passwordController.text,
      );
      await secureStorage.write(key: 'remember_me', value: 'true');
    } else {
      await secureStorage.delete(key: 'remembered_email');
      await secureStorage.delete(key: 'remembered_password');
      await secureStorage.write(key: 'remember_me', value: 'false');
    }
  }

  @override
  Future<void> close() {
    emailController.removeListener(validateFields);
    passwordController.removeListener(validateFields);
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
