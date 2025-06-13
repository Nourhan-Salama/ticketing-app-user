
// import 'package:easy_localization/easy_localization.dart';
// import 'package:final_app/Helper/Custom-big-button.dart';
// import 'package:final_app/screens/user-dashboard.dart';
// import 'package:final_app/services/login-service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:final_app/cubits/login/login-cubit.dart';
// import 'package:final_app/cubits/login/login-state.dart';
// import 'package:final_app/Helper/custom-textField.dart';
// import 'package:final_app/screens/rest-screen.dart';
// import 'package:final_app/screens/sign-up.dart';
// import 'package:final_app/util/colors.dart';
// import 'package:final_app/util/responsive-helper.dart';
// import 'package:final_app/cubits/profile/profile-cubit.dart'; // Added for ProfileCubit

// class LoginScreen extends StatefulWidget {
//   static const String routeName = '/login';
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
//       GlobalKey<ScaffoldMessengerState>();
      
//   final AuthApi _authApi = AuthApi(); // Added for checkLoginStatus
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Added for onLoginPressed
//   bool _isLoading = false; // Added for onLoginPressed
//   final TextEditingController _emailController = TextEditingController(); // Added for onLoginPressed
//   final TextEditingController _passwordController = TextEditingController(); // Added for onLoginPressed

//   // Add these methods as requested >>>>
//   void onLoginPressed() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final authApi = AuthApi();
//       final result = await authApi.login(
//         email: _emailController.text.trim(),
//         password: _passwordController.text,
//       );

//       if (result['code'] == 200) {
//         // ✅ Clear any existing profile state
//         if (mounted) {
//           context.read<ProfileCubit>().clearProfile();
//         }

//         // ✅ Navigate to dashboard
//         if (mounted) {
//           Navigator.pushNamedAndRemoveUntil(
//             context,
//             UserDashboard.routeName,
//             (route) => false,
//           );

//           // ✅ Load new user's profile after navigation
//           context.read<ProfileCubit>().loadProfile();
//         }
//       } else {
//         // Handle login error
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(result['message'] ?? 'Login failed'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Login error: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   // ✅ Add method to check login status on app start
//   void checkLoginStatus() async {
//     final authApi = AuthApi();
//     final isLoggedIn = await authApi.isLoggedIn();
    
//     if (isLoggedIn) {
//       // User is logged in, get their info
//       final userInfo = await authApi.getCurrentUserInfo();
//       print('Current user: ${userInfo['email']}');
      
//       // Load profile
//       if (mounted) {
//         context.read<ProfileCubit>().loadProfile();
//       }
//     } else {
//       // User is not logged in, clear any cached data
//       if (mounted) {
//         context.read<ProfileCubit>().clearProfile();
//       }
//     }
//   }

//   // ✅ Call this in initState or when app starts
//   @override
//   void initState() {
//     super.initState();
//     checkLoginStatus();
//   }
//   // <<<< Added methods end here

//   @override
//   Widget build(BuildContext context) {
//     return ScaffoldMessenger(
//       key: _scaffoldMessengerKey,
//       child: Scaffold(
//         body: BlocProvider(
//           create: (context) => LoginCubit(
//             authApi: AuthApi(),
//           ),
//           child: BlocListener<LoginCubit, LoginState>(
//             listener: (context, state) {
//               if (state.isSuccess) {
//                 Navigator.pushNamedAndRemoveUntil(
//                   context,
//                   UserDashboard.routeName,
//                   (route) => false,
//                 );
//               }
//               if (state.errorMessage != null && !state.isLoading) {
//                 _scaffoldMessengerKey.currentState?.showSnackBar(
//                   SnackBar(
//                     content: Text(state.errorMessage!),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//                 context.read<LoginCubit>().clearError();
//               }
//             },
//             child: _buildBody(context),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBody(BuildContext context) {
//     return SingleChildScrollView(
//       child: ConstrainedBox(
//         constraints: BoxConstraints(
//           minHeight: ResponsiveHelper.screenHeight(context),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildHeader(context),
//             SizedBox(height: ResponsiveHelper.heightPercent(context, 0.05)),
//             _buildFormContent(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Container(
//       height: ResponsiveHelper.responsiveValue(
//         context: context,
//         mobile: ResponsiveHelper.heightPercent(context, 0.30),
//         tablet: ResponsiveHelper.heightPercent(context, 0.25),
//         desktop: ResponsiveHelper.heightPercent(context, 0.20),
//       ),
//       decoration: BoxDecoration(
//         color: ColorsHelper.CreateNewButtonColor,
//         borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
//       ),
//       child: Center(
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: ResponsiveHelper.widthPercent(context, 0.05),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 "welcomeBack".tr(),
//                 style: TextStyle(
//                   fontSize: ResponsiveHelper.responsiveTextSize(context, 22),
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               SizedBox(height: ResponsiveHelper.heightPercent(context, 0.01)),
//               Text(
//                 "loginMessage".tr(),
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: ResponsiveHelper.responsiveTextSize(context, 16),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFormContent(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: ResponsiveHelper.responsiveValue(
//           context: context,
//           mobile: 20,
//           tablet: 40,
//           desktop: 80,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           _buildSignInText(context),
//           SizedBox(height: ResponsiveHelper.heightPercent(context, 0.03)),
//           _buildEmailField(context),
//           SizedBox(height: ResponsiveHelper.heightPercent(context, 0.02)),
//           _buildPasswordField(context),
//           SizedBox(height: ResponsiveHelper.heightPercent(context, 0.02)),
//           _buildRememberMeAndForgotPassword(context),
//           SizedBox(height: ResponsiveHelper.heightPercent(context, 0.03)),
//           _buildSignUpLink(context),
//           SizedBox(height: ResponsiveHelper.heightPercent(context, 0.03)),
//           _buildSignInButton(context),
//         ],
//       ),
//     );
//   }

//   Widget _buildSignInText(BuildContext context) {
//     return Text(
//       "login".tr(),
//       style: TextStyle(
//         fontSize: ResponsiveHelper.responsiveTextSize(context, 18),
//         fontWeight: FontWeight.bold,
//       ),
//       textAlign: TextAlign.center,
//     );
//   }

//   Widget _buildEmailField(BuildContext context) {
//     return BlocBuilder<LoginCubit, LoginState>(
//       builder: (context, state) {
//         return CustomTextField(
//           label: 'Email'.tr(),
//           controller: context.read<LoginCubit>().emailController,
//           hintText: 'enterYourEmail'.tr(),
//           prefixIcon: Icons.email,
//           keyboardType: TextInputType.emailAddress,
//           errorText: state.emailError,
//           onChanged: (value) => context.read<LoginCubit>().validateFields(),
//         );
//       },
//     );
//   }

//   Widget _buildPasswordField(BuildContext context) {
//     return BlocBuilder<LoginCubit, LoginState>(
//       builder: (context, state) {
//         return CustomTextField(
//           label: 'password'.tr(),
//           controller: context.read<LoginCubit>().passwordController,
//           hintText: 'enterYourPassword'.tr(),
//           prefixIcon: Icons.lock,
//           obscureText: state.obscurePassword,
//           errorText: state.passwordError,
//           suffixIcon:
//               state.obscurePassword ? Icons.visibility_off : Icons.visibility,
//           onSuffixPressed: () =>
//               context.read<LoginCubit>().togglePasswordVisibility(),
//           onChanged: (value) => context.read<LoginCubit>().validateFields(),
//         );
//       },
//     );
//   }

//   Widget _buildRememberMeAndForgotPassword(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         BlocBuilder<LoginCubit, LoginState>(
//           builder: (context, state) {
//             return Row(
//               children: [
//                 Checkbox(
//                   value: state.rememberMe,
//                   onChanged: (value) => context
//                       .read<LoginCubit>()
//                       .toggleRememberMe(value ?? false),
//                 ),
//                 Text(
//                   "rememberMe".tr(),
//                   style: TextStyle(
//                     fontSize: ResponsiveHelper.responsiveTextSize(context, 14),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//         TextButton(
//           onPressed: () => Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
//           ),
//           child: Text(
//             "forgetPassword".tr(),
//             style: TextStyle(
//               color: ColorsHelper.darkBlue,
//               fontSize: ResponsiveHelper.responsiveTextSize(context, 14),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSignUpLink(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           "dontHaveAnAccount".tr(),
//           style: TextStyle(
//             fontSize: ResponsiveHelper.responsiveTextSize(context, 14),
//           ),),
//         GestureDetector(
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => SignUpScreen()),
//           ),
//           child: Text(
//             'createAccount'.tr(),
//             style: TextStyle(
//               color: ColorsHelper.darkBlue,
//               fontWeight: FontWeight.bold,
//               fontSize: ResponsiveHelper.responsiveTextSize(context, 14),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSignInButton(BuildContext context) {
//     return BlocBuilder<LoginCubit, LoginState>(
//       builder: (context, state) {
//         return Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: ResponsiveHelper.responsiveValue(
//               context: context,
//               mobile: 0,
//               tablet: 40,
//               desktop: 80,
//             ),
//           ),
//           child: SubmitButton(
//             isEnabled: state.isButtonEnabled && !state.isLoading,
//             onPressed: state.isButtonEnabled && !state.isLoading
//                 ? () => context.read<LoginCubit>().login()
//                 : null,
//             buttonText: state.isLoading ? 'loading'.tr() : 'login'.tr(),
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:easy_localization/easy_localization.dart';
import 'package:final_app/Helper/Custom-big-button.dart';
import 'package:final_app/screens/user-dashboard.dart';
import 'package:final_app/services/login-service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_app/cubits/login/login-cubit.dart';
import 'package:final_app/cubits/login/login-state.dart';
import 'package:final_app/Helper/custom-textField.dart';
import 'package:final_app/screens/rest-screen.dart';
import 'package:final_app/screens/sign-up.dart';
import 'package:final_app/util/colors.dart';
import 'package:final_app/util/responsive-helper.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        body: BlocProvider(
          create: (context) => LoginCubit(
            authApi: AuthApi(),
          ),
          child: BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state.isSuccess) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  UserDashboard.routeName,
                  (route) => false,
                );
              }
              if (state.errorMessage != null && !state.isLoading) {
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
                context.read<LoginCubit>().clearError();
              }
            },
            child: _buildBody(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: ResponsiveHelper.screenHeight(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            SizedBox(height: ResponsiveHelper.heightPercent(context, 0.05)),
            _buildFormContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: ResponsiveHelper.responsiveValue(
        context: context,
        mobile: ResponsiveHelper.heightPercent(context, 0.30),
        tablet: ResponsiveHelper.heightPercent(context, 0.25),
        desktop: ResponsiveHelper.heightPercent(context, 0.20),
      ),
      decoration: BoxDecoration(
        color: ColorsHelper.CreateNewButtonColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.widthPercent(context, 0.05),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "welcomeBack".tr(),
                style: TextStyle(
                  fontSize: ResponsiveHelper.responsiveTextSize(context, 22),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: ResponsiveHelper.heightPercent(context, 0.01)),
              Text(
                "loginMessage".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: ResponsiveHelper.responsiveTextSize(context, 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.responsiveValue(
          context: context,
          mobile: 20,
          tablet: 40,
          desktop: 80,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSignInText(context),
          SizedBox(height: ResponsiveHelper.heightPercent(context, 0.03)),
          _buildEmailField(context),
          SizedBox(height: ResponsiveHelper.heightPercent(context, 0.02)),
          _buildPasswordField(context),
          SizedBox(height: ResponsiveHelper.heightPercent(context, 0.02)),
          _buildRememberMeAndForgotPassword(context),
          SizedBox(height: ResponsiveHelper.heightPercent(context, 0.03)),
          _buildSignUpLink(context),
          SizedBox(height: ResponsiveHelper.heightPercent(context, 0.03)),
          _buildSignInButton(context),
        ],
      ),
    );
  }

  Widget _buildSignInText(BuildContext context) {
    return Text(
      "login".tr(),
      style: TextStyle(
        fontSize: ResponsiveHelper.responsiveTextSize(context, 18),
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return CustomTextField(
          label: 'Email'.tr(),
          controller: context.read<LoginCubit>().emailController,
          hintText: 'enterYourEmail'.tr(),
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          errorText: state.emailError,
          onChanged: (value) => context.read<LoginCubit>().validateFields(),
        );
      },
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return CustomTextField(
          label: 'password'.tr(),
          controller: context.read<LoginCubit>().passwordController,
          hintText: 'enterYourPassword'.tr(),
          prefixIcon: Icons.lock,
          obscureText: state.obscurePassword,
          errorText: state.passwordError,
          suffixIcon:
              state.obscurePassword ? Icons.visibility_off : Icons.visibility,
          onSuffixPressed: () =>
              context.read<LoginCubit>().togglePasswordVisibility(),
          onChanged: (value) => context.read<LoginCubit>().validateFields(),
        );
      },
    );
  }

  Widget _buildRememberMeAndForgotPassword(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state) {
            return Row(
              children: [
                Checkbox(
                  value: state.rememberMe,
                  onChanged: (value) => context
                      .read<LoginCubit>()
                      .toggleRememberMe(value ?? false),
                ),
                Text(
                  "rememberMe".tr(),
                  style: TextStyle(
                    fontSize: ResponsiveHelper.responsiveTextSize(context, 14),
                  ),
                ),
              ],
            );
          },
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
          ),
          child: Text(
            "forgetPassword".tr(),
            style: TextStyle(
              color: ColorsHelper.darkBlue,
              fontSize: ResponsiveHelper.responsiveTextSize(context, 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "dontHaveAnAccount".tr(),
          style: TextStyle(
            fontSize: ResponsiveHelper.responsiveTextSize(context, 14),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignUpScreen()),
          ),
          child: Text(
            'createAccount'.tr(),
            style: TextStyle(
              color: ColorsHelper.darkBlue,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.responsiveTextSize(context, 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.responsiveValue(
              context: context,
              mobile: 0,
              tablet: 40,
              desktop: 80,
            ),
          ),
          child: SubmitButton(
            isEnabled: state.isButtonEnabled && !state.isLoading,
            onPressed: state.isButtonEnabled && !state.isLoading
                ? () => context.read<LoginCubit>().login()
                : null,
            buttonText: state.isLoading ? 'loading'.tr() : 'login'.tr(),
          ),
        );
      },
    );
  }
}
