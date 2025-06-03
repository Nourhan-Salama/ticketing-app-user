import 'package:easy_localization/easy_localization.dart';
import 'package:final_app/Helper/text-icon-button.dart';
import 'package:final_app/cubits/localization/localization-cubit.dart';
import 'package:final_app/screens/all-tickets.dart';
import 'package:final_app/screens/login.dart';
import 'package:final_app/screens/user-dashboard.dart';
import 'package:final_app/services/logout-service.dart';
import 'package:final_app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String? userName;
  String? userEmail;
  bool isUserInfoLoading = true;

  final AssetImage userAvatar = const AssetImage('assets/icons/formal.jpg');

  @override
  void initState() {
    super.initState();
    _precacheImage();
    _loadUserInfo();
  }

  Future<void> _precacheImage() async {
    await precacheImage(userAvatar, context);
  }

  Future<void> _loadUserInfo() async {
    final storage = FlutterSecureStorage();
    try {
      final name = await storage.read(key: 'user_name');
      final email = await storage.read(key: 'user_email');

      setState(() {
        userName = name;
        userEmail = email;
        isUserInfoLoading = false;
      });
    } catch (e) {
      print('Error loading user info: $e');
      setState(() {
        isUserInfoLoading = false;
      });
    }
  }

  String getCurrentRoute(BuildContext context) {
    return ModalRoute.of(context)?.settings.name ?? UserDashboard.routeName;
  }

  void navigateToScreen(BuildContext context, String routeName) {
    if (getCurrentRoute(context) == routeName) {
      Navigator.pop(context);
      return;
    }

    Navigator.pop(context);

    if (routeName == UserDashboard.routeName) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        routeName,
        (route) => false,
      );
    } else {
      Navigator.pushNamed(context, routeName);
    }
  }

  Future<void> _performLogout(BuildContext context) async {
    ScaffoldMessenger.of(context).clearSnackBars();

    final logoutService = LogoutService();
    final result = await logoutService.logout();

    if (!mounted) return;

    final storage = FlutterSecureStorage();
    final tokenAfterLogout = await storage.read(key: 'access_token');
    final refreshTokenAfterLogout = await storage.read(key: 'refresh_token');

    if (result['code'] == 200 &&
        tokenAfterLogout == null &&
        refreshTokenAfterLogout == null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginScreen.routeName,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentRoute = getCurrentRoute(context);

    return Drawer(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 15),
            _buildHeader(),
            const SizedBox(height: 40),
            TextIconButton(
              icon: Icons.dashboard,
              label: 'dashboard'.tr(),
              isSelected: currentRoute == UserDashboard.routeName,
              onPressed: () =>
                  navigateToScreen(context, UserDashboard.routeName),
            ),
            TextIconButton(
              icon: Icons.airplane_ticket,
              label: 'allTickets'.tr(),
              isSelected: currentRoute == AllTickets.routeName,
              onPressed: () => navigateToScreen(context, AllTickets.routeName),
            ),
            TextIconButton(
              icon: Icons.language,
              label: 'Language'.tr(),
              isSelected: false,
              onPressed: () => _showLanguageDialog(context),
            ),
            const Spacer(),
            Align(
              child: TextIconButton(
                icon: Icons.logout,
                label: 'logout'.tr(),
                onPressed: () => _performLogout(context),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localizationCubit = context.read<LocalizationCubit>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('chooseLanguage'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('English'),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  await localizationCubit.updateLocale('en');
                  if (mounted) {
                    context.setLocale(const Locale('en'));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('العربية'),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  await localizationCubit.updateLocale('ar');
                  if (mounted) {
                    context.setLocale(const Locale('ar'));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    if (isUserInfoLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    String name = userName ?? 'Hello Guest';
    String email = userEmail ?? '';

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: ColorsHelper.darkBlue,
              borderRadius: BorderRadius.circular(5),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: userAvatar,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                email,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

