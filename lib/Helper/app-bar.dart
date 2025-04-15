import 'dart:io';
import 'package:final_app/cubits/prpfile-state.dart';
import 'package:final_app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_app/cubits/profile-cubit.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  String? imagePath;
                  if (state is ProfileLoaded) {
                    imagePath = state.imagePath;
                  }

                  return Container(
                    width: 47,
                    height: 47,
                    decoration: BoxDecoration(
                      color: ColorsHelper.darkBlue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundImage: (imagePath != null && imagePath.isNotEmpty)
                          ? FileImage(File(imagePath)) as ImageProvider
                          : const AssetImage('assets/icons/avatar.png'),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: -5,
                right: -10,
                child: Material(
                  type: MaterialType.circle,
                  color: Colors.white,
                  elevation: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu,
                        size: 13,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
