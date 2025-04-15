import 'dart:io';
import 'package:final_app/cubits/prpfile-state.dart';
import 'package:final_app/screens/login.dart';
import 'package:final_app/services/logout-service.dart';
import 'package:final_app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_app/cubits/profile-cubit.dart';
import 'package:final_app/Helper/text-icon-button.dart';
import 'package:final_app/screens/all-tickets.dart';
import 'package:final_app/screens/chat-page.dart';
import 'package:final_app/screens/edit-profile.dart';
import 'package:final_app/screens/user-dashboard.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String getCurrentRoute(BuildContext context) {
    return ModalRoute.of(context)?.settings.name ??
        UserDashboard.routeName; // Default
  }

  void navigateToScreen(BuildContext context, String routeName) {
    if (getCurrentRoute(context) == routeName) {
      Navigator.pop(
          context); // If already on the same page, just close the drawer
      return;
    }

    Navigator.pop(context); // Close the drawer

    if (routeName == '/dashboard') {
      // Reset the navigation stack when going to Dashboard
      Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
    } else {
      Navigator.pushNamed(context, routeName);
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
            buildHeader(context),
            const SizedBox(height: 40),
            TextIconButton(
              icon: Icons.dashboard,
              label: 'Dashboard',
              isSelected: currentRoute == UserDashboard.routeName,
              onPressed: () =>
                  navigateToScreen(context, UserDashboard.routeName),
            ),
            TextIconButton(
              icon: Icons.airplane_ticket,
              label: 'All Tickets',
              isSelected: currentRoute == AllTickets.routeName,
              onPressed: () => navigateToScreen(context, AllTickets.routeName),
            ),
            TextIconButton(
              icon: Icons.chat,
              label: 'Chat',
              isSelected: currentRoute == ChatsPage.routeName,
              onPressed: () => navigateToScreen(context, ChatsPage.routeName),
            ),
            Align(
              child: TextIconButton(
                icon: Icons.logout,
                label: 'Logout',
                onPressed: () async {
                  final result = await LogoutService().logout();

                  if (!mounted) return;

                  if (result['code'] == 200) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      LoginScreen.routeName,
                      (route) => false,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'])),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(result['message'] ?? 'Logout failed')),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        String? imagePath;
        if (state is ProfileLoaded) {
          imagePath = state.imagePath;
        }

        return Row(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  backgroundImage: (imagePath != null && imagePath.isNotEmpty)
                      ? FileImage(File(imagePath)) as ImageProvider
                      : const AssetImage('assets/icons/avatar.png'),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Nourhan Salama',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'May 12 2024',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context); // Close drawer first
                Navigator.pushNamed(context, ProfileScreen.routeName);
              },
              icon: const Icon(Icons.edit),
              iconSize: 20,
            )
          ],
        );
      },
    );
  }
}
