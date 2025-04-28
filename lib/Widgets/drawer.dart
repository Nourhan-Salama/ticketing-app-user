import 'dart:async';
import 'dart:io';
import 'package:final_app/cubits/prpfile-state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:final_app/cubits/profile-cubit.dart';
import 'package:final_app/screens/login.dart';
import 'package:final_app/services/logout-service.dart';
import 'package:final_app/util/colors.dart';
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
  final _storage = FlutterSecureStorage();
  StreamSubscription? _profileSubscription;
  String name = 'Hello Guest';
  String email = '';
  String? imagePath;

  @override
  void initState() {
    super.initState();
    _loadInitialUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to profile changes
    _profileSubscription = context.read<ProfileCubit>().stream.listen((state) {
      if (state is ProfileLoaded) {
        _updateUserData(
          name: state.fullName,
          email: state.email,
          imagePath: state.imagePath,
        );
      }
    });
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialUserData() async {
    try {
      final firstName = await _storage.read(key: 'firstName') ?? '';
      final lastName = await _storage.read(key: 'lastName') ?? '';
      final userEmail = await _storage.read(key: 'email') ?? '';
      final userImagePath = await _storage.read(key: 'imagePath') ?? '';

      final fullName = '$firstName $lastName'.trim();

      if (mounted) {
        setState(() {
          name = fullName.isNotEmpty ? fullName : 'Hello Guest';
          email = userEmail;
          imagePath = userImagePath;
        });
      }
    } catch (e) {
      debugPrint('Error loading initial user data: $e');
    }
  }

  Future<void> _updateUserData({
    required String name,
    required String email,
    String? imagePath,
  }) async {
    try {
      await _storage.write(key: 'firstName', value: name.split(' ').first);
      await _storage.write(key: 'lastName', 
          value: name.split(' ').length > 1 ? name.split(' ').sublist(1).join(' ') : '');
      await _storage.write(key: 'email', value: email);
      await _storage.write(key: 'imagePath', value: imagePath ?? '');

      if (mounted) {
        setState(() {
          this.name = name;
          this.email = email;
          this.imagePath = imagePath;
        });
      }
    } catch (e) {
      debugPrint('Error updating user data: $e');
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
      Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
    } else {
      Navigator.pushNamed(context, routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = getCurrentRoute(context);
    final profileState = context.watch<ProfileCubit>().state;

    // Update from profile state if available
    if (profileState is ProfileLoaded) {
      name = profileState.fullName.isNotEmpty 
          ? profileState.fullName 
          : 'Hello Guest';
      email = profileState.email;
      imagePath = profileState.imagePath;
    }

    return Drawer(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 15),
            _buildHeader(context, name, email, imagePath),
            const SizedBox(height: 40),
            TextIconButton(
              icon: Icons.dashboard,
              label: 'Dashboard',
              isSelected: currentRoute == UserDashboard.routeName,
              onPressed: () => navigateToScreen(context, UserDashboard.routeName),
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
            const Spacer(),
            Align(
              child: TextIconButton(
                icon: Icons.logout,
                label: 'Logout',
                onPressed: () async {
                  final result = await LogoutService().logout();
                  
                  if (!mounted) return;

                  // Clear all stored user data on logout
                  await _storage.delete(key: 'firstName');
                  await _storage.delete(key: 'lastName');
                  await _storage.delete(key: 'email');
                  await _storage.delete(key: 'imagePath');

                  if (result['code'] == 200) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      LoginScreen.routeName,
                      (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'] ?? 'Logout failed')),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String email, String? imagePath) {
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
              backgroundImage: _getImageProvider(imagePath),
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
        IconButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, EditProfileScreen.routeName)
                .then((_) => context.read<ProfileCubit>().loadProfile());
          },
          icon: const Icon(Icons.edit),
          iconSize: 20,
        ),
      ],
    );
  }

  ImageProvider _getImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const AssetImage('assets/icons/avatar.png');
    }
    
    try {
      final file = File(imagePath);
      if (file.existsSync()) {
        return FileImage(file)..evict();
      }
      return const AssetImage('assets/icons/avatar.png');
    } catch (e) {
      debugPrint('Error loading profile image: $e');
      return const AssetImage('assets/icons/avatar.png');
    }
  }
}
