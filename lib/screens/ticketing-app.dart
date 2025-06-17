import 'package:easy_localization/easy_localization.dart';
import 'package:final_app/Helper/enum-helper.dart';
import 'package:final_app/cubits/conversations/conversation-cubit.dart';
import 'package:final_app/cubits/localization/localization-cubit.dart';
import 'package:final_app/cubits/notifications/notifications-cubit.dart';
import 'package:final_app/screens/change-password.dart';
import 'package:final_app/screens/chat-screen.dart';
import 'package:final_app/screens/notifications-screen.dart';
import 'package:final_app/screens/otp-screen.dart';
import 'package:final_app/screens/profile.dart';
import 'package:final_app/screens/splash-screen.dart';
import 'package:final_app/services/conversation-service.dart';
import 'package:final_app/services/localization-service.dart';
import 'package:final_app/services/notifications-services.dart';
import 'package:final_app/services/push-notification.dart';
import 'package:final_app/services/service-profile.dart';
import 'package:final_app/services/ticket-service.dart';
import 'package:final_app/services/verify_user_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:final_app/cubits/changePassword/change-pass-cubit.dart';
import 'package:final_app/cubits/createNewTicket/creat-new-cubit.dart';
import 'package:final_app/cubits/tickets/get-ticket-cubits.dart';
import 'package:final_app/cubits/profile/profile-cubit.dart';
import 'package:final_app/cubits/resetPassword/rest-password-cubit.dart';
import 'package:final_app/cubits/rich-text-cubit.dart';
import 'package:final_app/cubits/signUp/sign-up-cubit.dart';
import 'package:final_app/cubits/otp/otp-verification-cubit.dart';
import 'package:final_app/cubits/login/login-cubit.dart';

import 'package:final_app/services/login-service.dart';
import 'package:final_app/services/resend-otp-api.dart';
import 'package:final_app/services/send-forget-pass-api.dart';

import 'package:final_app/screens/login.dart';
import 'package:final_app/screens/all-tickets.dart';
import 'package:final_app/screens/create-new.dart';
import 'package:final_app/screens/edit-profile.dart';
import 'package:final_app/screens/user-dashboard.dart';
import 'package:final_app/screens/rest-screen.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class TicketingApp extends StatelessWidget {
  final String? accessToken;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  TicketingApp({super.key, this.accessToken});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => const FlutterSecureStorage()),
        RepositoryProvider(create: (_) => http.Client()),
        RepositoryProvider(
          create: (context) =>
              AuthApi(storage: context.read<FlutterSecureStorage>()),
        ),
        RepositoryProvider(create: (_) => VerifyUserApi()),
        RepositoryProvider(create: (_) => ResendOtpApi()),
        RepositoryProvider(create: (_) => ProfileService()),
        RepositoryProvider(create: (_) => SendForgetPassApi()),
        RepositoryProvider(create: (_) => TicketService()),
        RepositoryProvider(create: (_) => NotificationService()),
        RepositoryProvider(create: (_) => LocalizationService()),
        RepositoryProvider(create: (_) => ConversationsService()),
      ],
      child: Builder(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (_) =>
                      LoginCubit(authApi: context.read<AuthApi>())),
              BlocProvider(create: (_) => RichTextCubit()),
              BlocProvider(
                  create: (_) =>
                      TicketsCubit(context.read<TicketService>())),
              BlocProvider(create: (_) => CreateNewCubit()),
              BlocProvider(
                  create: (_) =>
                      ProfileCubit(context.read<ProfileService>())),
              BlocProvider(create: (_) => SignUpCubit()),
              BlocProvider(create: (_) => ChangePasswordCubit()),
              BlocProvider(
                  create: (_) =>
                      NotificationsCubit(context.read<NotificationService>())),
              BlocProvider(
                create: (_) => LocalizationCubit(
                  context.read<LocalizationService>(),
                ),
              ),
              BlocProvider(
                create: (_) => ConversationsCubit(
                  conversationsService: context.read<ConversationsService>(),
                ),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorObservers: [routeObserver],
              navigatorKey: navigatorKey,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: AccessRouter(accessToken: accessToken),
              routes: {
                SplashScreen.routeName: (_) => SplashScreen(),
                LoginScreen.routeName: (_) => LoginScreen(),
                UserDashboard.routeName: (_) => UserDashboard(),
                AllTickets.routeName: (_) => AllTickets(),
                '/notifications': (_) => const NotificationsScreen(),
                ChatScreen.routeName: (context) {
                  final args = ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>;
                  return ChatScreen(
                    userName: args['userName'],
                    conversationId: args['conversationId'],
                    currentUserId: args['currentUserId'],
                  );
                },
                EditProfileScreen.routeName: (_) => EditProfileScreen(),
                CreateNewScreen.routeName: (_) => CreateNewScreen(),
                ResetPasswordScreen.routeName: (context) {
                  final sendForgetPassApi =
                      context.read<SendForgetPassApi>();
                  return BlocProvider(
                    create: (_) => ResetPasswordCubit(sendForgetPassApi),
                    child: ResetPasswordScreen(),
                  );
                },
                ChangePasswordScreen.routeName: (_) => ChangePasswordScreen(
                      handle: '',
                      verificationCode: '',
                    ),
                OtpVerificationPage.routeName: (context) {
                  final args = ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>;
                  return BlocProvider(
                    create: (_) => OtpCubit(
                      context.read<VerifyUserApi>(),
                      context.read<ResendOtpApi>(),
                      args['email'],
                      args['otpType'],
                    ),
                    child: OtpVerificationPage(
                      email: args['email'],
                      otpType: args['otpType'],
                    ),
                  );
                },
              },
              builder: (context, child) {
                return AppInitializer(
                  navigatorKey: navigatorKey,
                  child: child!,
                );
              },
              theme: ThemeData(
                primarySwatch: Colors.blue,
                scaffoldBackgroundColor: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}

class AccessRouter extends StatelessWidget {
  final String? accessToken;

  const AccessRouter({super.key, this.accessToken});

  @override
  Widget build(BuildContext context) {
    return accessToken == null ? SplashScreen() : UserDashboard();
  }
}

class AppInitializer extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const AppInitializer({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await Future.delayed(const Duration(seconds: 1));
    await NotificationHandler.initialize(
      navigationKey: widget.navigatorKey,
      onReceived: () {
        final context = widget.navigatorKey.currentContext;
        if (context != null) {
          context.read<NotificationsCubit>().loadNotifications();
        }
      },
      onOpened: (notification) {
        final context = widget.navigatorKey.currentContext;
        if (context != null) {
          context.read<NotificationsCubit>().markAsRead(notification.id);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}



// import 'package:easy_localization/easy_localization.dart';
// import 'package:final_app/Helper/enum-helper.dart';
// import 'package:final_app/cubits/conversations/conversation-cubit.dart';
// import 'package:final_app/cubits/localization/localization-cubit.dart';
// import 'package:final_app/cubits/notifications/notifications-cubit.dart';
// import 'package:final_app/screens/change-password.dart';
// import 'package:final_app/screens/chat-screen.dart';
// import 'package:final_app/screens/notifications-screen.dart';
// import 'package:final_app/screens/otp-screen.dart';
// import 'package:final_app/screens/profile.dart';
// import 'package:final_app/screens/splash-screen.dart';
// import 'package:final_app/services/conversation-service.dart';
// import 'package:final_app/services/localization-service.dart';
// import 'package:final_app/services/notifications-services.dart';
// import 'package:final_app/services/push-notification.dart';
// import 'package:final_app/services/service-profile.dart';
// import 'package:final_app/services/ticket-service.dart';
// import 'package:final_app/services/verify_user_auth.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;

// import 'package:final_app/cubits/changePassword/change-pass-cubit.dart';
// import 'package:final_app/cubits/createNewTicket/creat-new-cubit.dart';
// import 'package:final_app/cubits/tickets/get-ticket-cubits.dart';
// import 'package:final_app/cubits/profile/profile-cubit.dart';
// import 'package:final_app/cubits/resetPassword/rest-password-cubit.dart';
// import 'package:final_app/cubits/rich-text-cubit.dart';
// import 'package:final_app/cubits/signUp/sign-up-cubit.dart';
// import 'package:final_app/cubits/otp/otp-verification-cubit.dart';
// import 'package:final_app/cubits/login/login-cubit.dart';

// import 'package:final_app/services/login-service.dart';
// import 'package:final_app/services/resend-otp-api.dart';
// import 'package:final_app/services/send-forget-pass-api.dart';

// import 'package:final_app/screens/login.dart';
// import 'package:final_app/screens/all-tickets.dart';

// import 'package:final_app/screens/create-new.dart';
// import 'package:final_app/screens/edit-profile.dart';
// import 'package:final_app/screens/user-dashboard.dart';
// import 'package:final_app/screens/rest-screen.dart';

// final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// class TicketingApp extends StatelessWidget {
//   final String? accessToken;
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   TicketingApp({super.key, this.accessToken});

//   @override
//   Widget build(BuildContext context) {
//     return MultiRepositoryProvider(
//       providers: [
//         RepositoryProvider(create: (_) => const FlutterSecureStorage()),
//         RepositoryProvider(create: (_) => http.Client()),
//         RepositoryProvider(
//           create: (context) =>
//               AuthApi(storage: context.read<FlutterSecureStorage>()),
//         ),
//         RepositoryProvider(create: (_) => VerifyUserApi()),
//         RepositoryProvider(create: (_) => ResendOtpApi()),
//         RepositoryProvider(create: (_) => ProfileService()),
//         RepositoryProvider(create: (_) => SendForgetPassApi()),
//         RepositoryProvider(create: (_) => TicketService()),
//         RepositoryProvider(create: (_) => NotificationService()),
//         RepositoryProvider(create: (_) => LocalizationService()),
//         RepositoryProvider(create: (_) => ConversationsService()),
//       ],
//       child: Builder(
//         builder: (context) {
//           return MultiBlocProvider(
//             providers: [
//               BlocProvider(
//                   create: (_) =>
//                       LoginCubit(authApi: context.read<AuthApi>())),
//               BlocProvider(create: (_) => RichTextCubit()),
//               BlocProvider(
//                   create: (_) =>
//                       TicketsCubit(context.read<TicketService>())),
//               BlocProvider(create: (_) => CreateNewCubit()),
//               BlocProvider(
//                   create: (_) =>
//                       ProfileCubit(context.read<ProfileService>())),
//               BlocProvider(create: (_) => SignUpCubit()),
//               BlocProvider(create: (_) => ChangePasswordCubit()),
//               BlocProvider(
//                   create: (_) =>
//                       NotificationsCubit(context.read<NotificationService>())),
//               BlocProvider(
//                 create: (_) => LocalizationCubit(
//                   context.read<LocalizationService>(),
//                 ),
//               ),
//               BlocProvider(
//                 create: (_) => ConversationsCubit(
//                   conversationsService: context.read<ConversationsService>(),
//                 ),
//               ),
//             ],
//             child: MaterialApp(
//               debugShowCheckedModeBanner: false,
//               navigatorObservers: [routeObserver],
//               navigatorKey: navigatorKey,
//               localizationsDelegates: context.localizationDelegates,
//               supportedLocales: context.supportedLocales,
//               locale: context.locale,
//               initialRoute: SplashScreen.routeName,
//               routes: {
//                 SplashScreen.routeName: (_) => SplashScreen(),
//                 LoginScreen.routeName: (_) => LoginScreen(),
//                 UserDashboard.routeName: (_) => UserDashboard(),
//                 AllTickets.routeName: (_) => AllTickets(),
//                 '/notifications': (_) => const NotificationsScreen(),
//                 ChatScreen.routeName: (context) {
//                   final args = ModalRoute.of(context)!.settings.arguments
//                       as Map<String, dynamic>;
//                   return ChatScreen(
//                     userName: args['userName'],
//                     conversationId: args['conversationId'],
//                     currentUserId: args['currentUserId'],
//                   );
//                 },
//                 EditProfileScreen.routeName: (_) => EditProfileScreen(),
//                // Profile.routName: (_) => Profile(),
//                 CreateNewScreen.routeName: (_) => CreateNewScreen(),
//                 ResetPasswordScreen.routeName: (context) {
//                   final sendForgetPassApi =
//                       context.read<SendForgetPassApi>();
//                   return BlocProvider(
//                     create: (_) => ResetPasswordCubit(sendForgetPassApi),
//                     child: ResetPasswordScreen(),
//                   );
//                 },
//                 ChangePasswordScreen.routeName: (_) => ChangePasswordScreen(
//                       handle: '',
//                       verificationCode: '',
//                     ),
//                 OtpVerificationPage.routeName: (context) {
//                   final args = ModalRoute.of(context)!.settings.arguments
//                       as Map<String, dynamic>;
//                   return BlocProvider(
//                     create: (_) => OtpCubit(
//                       context.read<VerifyUserApi>(),
//                       context.read<ResendOtpApi>(),
//                       args['email'],
//                       args['otpType'],
//                     ),
//                     child: OtpVerificationPage(
//                       email: args['email'],
//                       otpType: args['otpType'],
//                     ),
//                   );
//                 },
//               },
//               builder: (context, child) {
//                 return AppInitializer(
//                   navigatorKey: navigatorKey,
//                   child: child!,
//                 );
//               },
//               theme: ThemeData(
//                 primarySwatch: Colors.blue,
//                 scaffoldBackgroundColor: Colors.white,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class AppInitializer extends StatefulWidget {
//   final Widget child;
//   final GlobalKey<NavigatorState> navigatorKey;

//   const AppInitializer({
//     super.key,
//     required this.child,
//     required this.navigatorKey,
//   });

//   @override
//   State<AppInitializer> createState() => _AppInitializerState();
// }

// class _AppInitializerState extends State<AppInitializer> {
//   @override
//   void initState() {
//     super.initState();
//     _initializeNotifications();
//   }

//   Future<void> _initializeNotifications() async {
//     await Future.delayed(const Duration(seconds: 1));
//     await NotificationHandler.initialize(
//       navigationKey: widget.navigatorKey,
//       onReceived: () {
//         final context = widget.navigatorKey.currentContext;
//         if (context != null) {
//           context.read<NotificationsCubit>().loadNotifications();
//         }
//       },
//       onOpened: (notification) {
//         final context = widget.navigatorKey.currentContext;
//         if (context != null) {
//           context.read<NotificationsCubit>().markAsRead(notification.id);
//         }
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }

