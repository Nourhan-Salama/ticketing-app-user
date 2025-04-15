import 'package:final_app/Helper/enum-helper.dart';
import 'package:final_app/cubits/otp-verification-cubit.dart';
import 'package:final_app/cubits/sign-up-cubit.dart';
import 'package:final_app/cubits/sign-up-state.dart';
import 'package:final_app/screens/otp-screen.dart';
import 'package:final_app/services/resend-otp-api.dart';
import 'package:final_app/services/verify_user_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_app/Helper/custom-textField.dart';
import 'package:final_app/Helper/Custom-big-button.dart';
import 'package:final_app/util/colors.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = "";

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (_) => SignUpCubit(),
      child: Scaffold(
        body: BlocConsumer<SignUpCubit, SignUpState>(
          listener: (context, state) {
            if (state.isSuccess) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => OtpCubit(
                        context.read<
                            VerifyUserApi>(), // Get from RepositoryProvider
                        context.read<
                            ResendOtpApi>(), // Get from RepositoryProvider
                        state.email!, // Pass the actual user email
                          OtpType.verification
                        
                      ),
                      child: OtpVerificationPage(email: state.email!,otpType: OtpType.verification,),
                    ),
                  ));
            }

            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<SignUpCubit>();

            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section
                    Container(
                      height: screenHeight * 0.30,
                      decoration: BoxDecoration(
                        color: ColorsHelper.CreateNewButtonColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(screenWidth * 0.1),
                          bottomRight: Radius.circular(screenWidth * 0.1),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Create Account!",
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              "Sign up to get started",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: screenWidth * 0.04),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // Sign Up Form
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // First Name Field
                          CustomTextField(
                            successText: state.firstNameSuccess,
                            label: "First Name",
                            hintText: "Enter Your First Name",
                            prefixIcon: Icons.person,
                            errorText: state.firstNameError,
                            controller: cubit.firstNameController,
                            onChanged: (_) {
                              cubit.validateFields();
                              _formKey.currentState?.validate();
                            },
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Last Name Field
                          CustomTextField(
                            successText: state.lastNameSuccess,
                            label: "Last Name",
                            hintText: "Enter Your Last Name",
                            prefixIcon: Icons.person_outline,
                            errorText: state.lastNameError,
                            controller: cubit.lastNameController,
                            onChanged: (_) {
                              cubit.validateFields();
                              _formKey.currentState?.validate();
                            },
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Email Field
                          CustomTextField(
                            successText: state.emailSuccess,
                            label: "Email",
                            hintText: "Enter Your Email",
                            prefixIcon: Icons.email,
                            errorText: state.emailError,
                            controller: cubit.emailController,
                            onChanged: (value) {
                              email = value ?? "";
                              cubit.validateFields();
                              _formKey.currentState?.validate();
                            },
                            keyboardType: TextInputType.emailAddress,
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Password Field
                          CustomTextField(
                            successText: state.passwordSuccess,
                            label: "Password",
                            hintText: "Enter Your Password",
                            prefixIcon: Icons.lock,
                            suffixIcon: state.obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            onSuffixPressed: cubit.togglePasswordVisibility,
                            obscureText: state.obscurePassword,
                            errorText: state.passwordError,
                            controller: cubit.passwordController,
                            onChanged: (_) {
                              cubit.validateFields();
                              _formKey.currentState?.validate();
                            },
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Confirm Password Field
                          CustomTextField(
                            successText: state.confirmPasswordSuccess,
                            label: "Confirm Password",
                            hintText: "Confirm Your Password",
                            prefixIcon: Icons.lock,
                            suffixIcon: state.obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            onSuffixPressed:
                                cubit.toggleConfirmPasswordVisibility,
                            obscureText: state.obscureConfirmPassword,
                            errorText: state.confirmPasswordError,
                            controller: cubit.confirmPasswordController,
                            onChanged: (_) {
                              cubit.validateFields();
                              _formKey.currentState?.validate();
                            },
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          // Sign Up Button
                          SubmitButton(
                            isEnabled:
                                state.isButtonEnabled && !state.isLoading,
                            onPressed: () {
                              cubit.submitForm(context);
                            },
                            buttonText:
                                state.isLoading ? 'Signing Up...' : 'Sign Up',
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Login Navigation
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: RichText(
                              text: TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: screenWidth * 0.04),
                                children: [
                                  TextSpan(
                                    text: 'Login',
                                    style: TextStyle(
                                        color: ColorsHelper.darkBlue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
