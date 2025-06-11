// my_drawer.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:final_app/Helper/text-icon-button.dart';
import 'package:final_app/cubits/localization/localization-cubit.dart';
import 'package:final_app/cubits/profile/profile-cubit.dart';
import 'package:final_app/cubits/profile/prpfile-state.dart';
import 'package:final_app/screens/all-tickets.dart';
import 'package:final_app/screens/edit-profile.dart';
import 'package:final_app/screens/login.dart';
import 'package:final_app/screens/user-dashboard.dart';
import 'package:final_app/services/logout-service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:final_app/util/colors.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

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
    Navigator.pop(context);

    final storage = FlutterSecureStorage();
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    await storage.delete(key: 'user_name');
    await storage.delete(key: 'user_email');

    try {
      await LogoutService().logout();
    } catch (e) {
      print('Logout API error: $e');
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen.routeName,
      (route) => false,
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
                  if (context.mounted) {
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
                  if (context.mounted) {
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

  @override
  Widget build(BuildContext context) {
    String currentRoute = getCurrentRoute(context);
    const AssetImage defaultAvatar = AssetImage('assets/icons/avatar.png');

    return Drawer(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 15),
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                // Fetch profile on first build
                if (state is! ProfileLoaded || state.firstName.isEmpty) {
                  context.read<ProfileCubit>().loadProfile();
                }

                String name = 'Hello Guest';
                String email = '';
                ImageProvider avatarImage = defaultAvatar;

                if (state is ProfileLoaded) {
                  // Combine first and last name for display
                  name = '${state.firstName} ${state.lastName}'.trim();
                  if (name.isEmpty) name = 'Hello Guest';
                  email = state.email;
                  if (state.imagePath != null && state.imagePath!.isNotEmpty) {
                    avatarImage = NetworkImage(state.imagePath!);
                  }
                }

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
                          backgroundImage: avatarImage,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                tooltip: 'Edit Profile',
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    EditProfileScreen.routeName,
                                  ).then((_) {
                                    context.read<ProfileCubit>().loadProfile();
                                  });
                                },
                              ),
                            ],
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
              },
            ),
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
}