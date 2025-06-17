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

  // ✅ Updated logout method with complete cleanup
  Future<void> _performLogout(BuildContext context) async {
    Navigator.pop(context);

    try {
      // ✅ Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // ✅ Clear profile state first
      context.read<ProfileCubit>().clearProfile();

      // ✅ Clear all stored data
      const storage = FlutterSecureStorage();
      await storage.deleteAll(); // This clears ALL stored data

      // ✅ Alternative: Clear specific keys if you want to keep some data
      // await storage.delete(key: 'access_token');
      // await storage.delete(key: 'refresh_token');
      // await storage.delete(key: 'user_name');
      // await storage.delete(key: 'user_email');
      // await storage.delete(key: 'user_id');
      // await storage.delete(key: 'remembered_email');
      // await storage.delete(key: 'remembered_password');

      // ✅ Call logout service
      try {
        await LogoutService().logout();
      } catch (e) {
        print('Logout API error: $e');
      }

      // ✅ Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // ✅ Navigate to login
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginScreen.routeName,
          (route) => false,
        );
      }

      // ✅ Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // ✅ Close loading dialog on error
      if (context.mounted) Navigator.pop(context);

      // ✅ Force logout even on error
      try {
        context.read<ProfileCubit>().clearProfile();
        const storage = FlutterSecureStorage();
        await storage.deleteAll();
      } catch (e) {
        print('Force logout error: $e');
      }

      // ✅ Navigate to login
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginScreen.routeName,
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout completed (local data cleared)'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
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

    // ✅ Always refresh profile when drawer opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileCubit>().refreshProfile();
    });

    return Drawer(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 15),
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                String name = 'Hello Guest';
                String email = '';
                ImageProvider avatarImage = defaultAvatar;

                if (state is ProfileLoaded) {
                  // ✅ Combine first and last name for display
                  name = '${state.firstName} ${state.lastName}'.trim();
                  if (name.isEmpty) name = 'Hello Guest';
                  email = state.email;
                  if (state.imagePath != null && state.imagePath!.isNotEmpty) {
                    avatarImage = NetworkImage(state.imagePath!);
                  }
                } else if (state is ProfileLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is ProfileError) {
                  return Center(
                    child: Column(
                      children: [
                        Text('Error: ${state.message}'),
                        ElevatedButton(
                          onPressed: () => context.read<ProfileCubit>().loadProfile(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
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
                                    // ✅ Refresh profile after editing
                                    context.read<ProfileCubit>().refreshProfile();
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
