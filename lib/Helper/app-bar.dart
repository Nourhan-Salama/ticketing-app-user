import 'package:final_app/Widgets/notifications-badge.dart';
import 'package:final_app/cubits/profile/profile-cubit.dart';
import 'package:final_app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:final_app/cubits/profile/prpfile-state.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onPressed;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onPressed,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;

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
        leading: Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(
                left: isRTL ? 0 : 7.0,
                right: isRTL ? 8.0 : 0,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  InkWell(
                    onTap: onPressed ?? () => Scaffold.of(context).openDrawer(),
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      width: 47,
                      height: 47,
                      margin: EdgeInsets.only(
                        left: isRTL ? 0 : 8.0,
                        right: isRTL ? 8.0 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: ColorsHelper.darkBlue,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: BlocBuilder<ProfileCubit, ProfileState>(
                        builder: (context, state) {
                          String? imageUrl;
                          if (state is ProfileLoaded &&
                              state.imagePath != null &&
                              state.imagePath!.isNotEmpty) {
                            imageUrl = state.imagePath!;
                          }

                          return CircleAvatar(
                            radius: 22,
                            // backgroundImage: imageUrl != null
                            //     ? NetworkImage(imageUrl)
                            //     : const AssetImage('assets/icons/avatar.jpg') as ImageProvider,
                            backgroundImage: NetworkImage(imageUrl ??
                                'data:image/png;base64,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'),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: isRTL ? null : -7,
                    left: isRTL ? -7 : null,
                    child: Material(
                      type: MaterialType.circle,
                      color: Colors.white,
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: onPressed ?? () => Scaffold.of(context).openDrawer(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
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
            );
          },
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
          const NotificationBadge(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


