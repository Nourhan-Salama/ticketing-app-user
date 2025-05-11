import 'package:final_app/Helper/Custom-big-button.dart';
import 'package:final_app/Helper/custom-textField.dart';
import 'package:final_app/Helper/enum-helper.dart';
import 'package:final_app/cubits/rest-password-cubit.dart';
import 'package:final_app/cubits/rest-password-state.dart';
import 'package:final_app/screens/otp-screen.dart';
import 'package:flutter/material.dart';
import 'package:final_app/util/responsive-helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_app/services/send-forget-pass-api.dart';

class ResetPasswordScreen extends StatelessWidget {
  static const String routeName = '/rest-password';

  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // نحاول نوصل للكيوبيت
    final maybeCubit = context.read<ResetPasswordCubit?>();

    // لو مش موجود، نغلف الصفحة كلها بالكيوبيت
    if (maybeCubit == null) {
      final api = context.read<SendForgetPassApi>();

      return BlocProvider(
        create: (_) => ResetPasswordCubit(api),
        child: const ResetPasswordScreen(),
      );
    }

    return const _ResetPasswordScreenContent();
  }
}

class _ResetPasswordScreenContent extends StatefulWidget {
  const _ResetPasswordScreenContent();

  @override
  State<_ResetPasswordScreenContent> createState() =>
      _ResetPasswordScreenContentState();
}

class _ResetPasswordScreenContentState
    extends State<_ResetPasswordScreenContent> {

  @override
  void dispose() {
 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<ResetPasswordCubit, ResetPasswordState>(
          listener: (context, state) {
            if (state is ResetPasswordSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => OtpVerificationPage(
                    email: state.email,
                    otpType: OtpType.resetPassword,
                  ),
                ),
              );
            } else if (state is ResetPasswordFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: ResponsiveHelper.responsivePadding(context),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: ResponsiveHelper.screenHeight(context) -
                    ResponsiveHelper.safeAreaTop(context) -
                    ResponsiveHelper.safeAreaBottom(context),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderSection(context),
                  SizedBox(height: ResponsiveHelper.heightPercent(context, 0.03)),
                  _buildInstructionText(context),
                  SizedBox(height: ResponsiveHelper.heightPercent(context, 0.04)),
                  _buildEmailField(context),
                  SizedBox(height: ResponsiveHelper.heightPercent(context, 0.05)),
                  _buildResetButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      children: [
        Text(
          'Reset Your Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.responsiveValue(
              context: context,
              mobile: 22,
              tablet: 26,
              desktop: 30,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionText(BuildContext context) {
    return Column(
      children: [
        Text(
          'We will send an email with',
          style: TextStyle(
              fontSize: ResponsiveHelper.responsiveTextSize(context, 14)),
        ),
        Text(
          'instructions to reset password.',
          style: TextStyle(
              fontSize: ResponsiveHelper.responsiveTextSize(context, 14)),
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
      builder: (context, state) {
        return CustomTextField(
          label: 'Email',
          controller: context.read<ResetPasswordCubit>().emailController,
          prefixIcon: Icons.email,
          hintText: 'Enter your Email',
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            context.read<ResetPasswordCubit>().updateButtonState(value!);
          },
        );
      },
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
      builder: (context, state) {
        final isEnabled = state is ResetPasswordButtonState && state.isEnabled;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.responsiveValue(
              context: context,
              mobile: 0,
              tablet: ResponsiveHelper.widthPercent(context, 0.2),
              desktop: ResponsiveHelper.widthPercent(context, 0.3),
            ),
          ),
          child: SubmitButton(
            isEnabled: isEnabled,
            onPressed: isEnabled
                ? () {
                    context
                        .read<ResetPasswordCubit>()
                        .resetPassword(context.read<ResetPasswordCubit>().emailController.text);
                  }
                : null,
            buttonText: 'Reset Password',
          ),
        );
      },
    );
  }
}

