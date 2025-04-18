// //test one
// import 'dart:io';
// import 'package:final_app/cubits/profile-cubit.dart';
// import 'package:final_app/screens/login.dart';
// import 'package:final_app/services/logout-service.dart';
// import 'package:final_app/util/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:final_app/Helper/text-icon-button.dart';
// import 'package:final_app/screens/all-tickets.dart';
// import 'package:final_app/screens/chat-page.dart';
// import 'package:final_app/screens/edit-profile.dart';
// import 'package:final_app/screens/user-dashboard.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class MyDrawer extends StatefulWidget {
//   const MyDrawer({super.key});

//   @override
//   State<MyDrawer> createState() => _MyDrawerState();
// }

// class _MyDrawerState extends State<MyDrawer> {
//   String? firstName;
//   String? lastName;
//   String? userEmail;
//   String? userImagePath;
//   bool isUserInfoLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserInfo();
//   }

//   Future<void> _loadUserInfo() async {
//     final storage = FlutterSecureStorage();
//     try {
//       setState(() => isUserInfoLoading = true);
      
//       // Load all data at once
//       final data = await storage.readAll();
      
//       setState(() {
//         firstName = data['user_first_name'];
//         lastName = data['user_last_name'];
//         userEmail = data['user_email'];
//         userImagePath = data['user_image_path'];
//         isUserInfoLoading = false;
//       });
//     } catch (e) {
//       print('Error loading user info: $e');
//       setState(() => isUserInfoLoading = false);
//     }
//   }

//   String getCurrentRoute(BuildContext context) {
//     return ModalRoute.of(context)?.settings.name ?? UserDashboard.routeName;
//   }

//   void navigateToScreen(BuildContext context, String routeName) {
//     if (getCurrentRoute(context) == routeName) {
//       Navigator.pop(context);
//       return;
//     }

//     Navigator.pop(context);

//     if (routeName == UserDashboard.routeName) {
//       Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
//     } else {
//       Navigator.pushNamed(context, routeName);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     String currentRoute = getCurrentRoute(context);

//     return Drawer(
//       backgroundColor: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 15),
//             _buildHeader(context),
//             const SizedBox(height: 40),
//             TextIconButton(
//               icon: Icons.dashboard,
//               label: 'Dashboard',
//               isSelected: currentRoute == UserDashboard.routeName,
//               onPressed: () =>
//                   navigateToScreen(context, UserDashboard.routeName),
//             ),
//             TextIconButton(
//               icon: Icons.airplane_ticket,
//               label: 'All Tickets',
//               isSelected: currentRoute == AllTickets.routeName,
//               onPressed: () => navigateToScreen(context, AllTickets.routeName),
//             ),
//             TextIconButton(
//               icon: Icons.chat,
//               label: 'Chat',
//               isSelected: currentRoute == ChatsPage.routeName,
//               onPressed: () => navigateToScreen(context, ChatsPage.routeName),
//             ),
//             const Spacer(),
//             Align(
//               child: TextIconButton(
//                 icon: Icons.logout,
//                 label: 'Logout',
//                 onPressed: () async {
//                   final result = await LogoutService().logout();

//                   if (!mounted) return;

//                   if (result['code'] == 200) {
//                     context.read<ProfileCubit>().clearLocalProfile();
//                     Navigator.pushNamedAndRemoveUntil(
//                       context,
//                       LoginScreen.routeName,
//                       (route) => false,
//                     );

//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text(result['message'])),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                           content: Text(result['message'] ?? 'Logout failed')),
//                     );
//                   }
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     if (isUserInfoLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Row(
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 8.0),
//           child: Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: ColorsHelper.darkBlue,
//               borderRadius: BorderRadius.circular(5),
//             ),
//             child: CircleAvatar(
//               radius: 30,
//               backgroundImage: _getImageProvider(userImagePath),
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                '${firstName ?? ''} ${lastName ?? ''}'.trim(),
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               Text(
//                 userEmail ?? '',
//                 style: const TextStyle(color: Colors.grey, fontSize: 12),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//         IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//             Navigator.pushNamed(context, EditProfileScreen.routeName)
//                 .then((_) {
//               _loadUserInfo(); // Refresh user info after returning from edit
//             });
//           },
//           icon: const Icon(Icons.edit),
//           iconSize: 20,
//         ),
//       ],
//     );
//   }

//   ImageProvider _getImageProvider(String? imagePath) {
//     if (imagePath == null || imagePath.isEmpty) {
//       return const AssetImage('assets/icons/avatar.png');
//     }
//     return FileImage(File(imagePath));
//   }
// }

import 'dart:io';
import 'package:final_app/cubits/profile-cubit.dart';
import 'package:final_app/screens/login.dart';
import 'package:final_app/services/logout-service.dart';
import 'package:final_app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:final_app/Helper/text-icon-button.dart';
import 'package:final_app/screens/all-tickets.dart';
import 'package:final_app/screens/chat-page.dart';
import 'package:final_app/screens/edit-profile.dart';
import 'package:final_app/screens/user-dashboard.dart';
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
  String? userImagePath;
  bool isUserInfoLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final storage = FlutterSecureStorage();
    try {
      final name = await storage.read(key: 'user_name');
      final email = await storage.read(key: 'user_email');
      final imagePath = await storage.read(key: 'user_image_path'); 

      setState(() {
        userName = name;
        userEmail = email;
        userImagePath = imagePath;
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
            _buildHeader(context),
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
            const Spacer(),
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
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (isUserInfoLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    String name = userName ?? 'Hello Gust';
    String email = userEmail ?? '';
    String? imageUrl;

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
              backgroundImage: _getImageProvider(imageUrl),
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
        // IconButton(
        //   onPressed: () async {
        //     Navigator.pop(context);

        //     await Navigator.pushNamed(context, EditProfileScreen.routeName);

        //     await _loadUserInfo();
        //   },
        //   icon: const Icon(Icons.edit),
        //   iconSize: 20,
        // ),

        IconButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, EditProfileScreen.routeName)
                .then((_) {
              context.read<ProfileCubit>().loadProfile();
            });
          },
          icon: const Icon(Icons.edit),
          iconSize: 20,
        ),
      ],
    );
  }

  ImageProvider _getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const AssetImage('assets/icons/avatar.png');
    }
    return FileImage(File(imageUrl));
  }
}
