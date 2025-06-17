

import 'dart:io';
import 'package:final_app/Helper/Custom-big-button.dart';
import 'package:final_app/Helper/app-bar.dart';
import 'package:final_app/Helper/custom-textField.dart';
import 'package:final_app/Widgets/drawer.dart';
import 'package:final_app/cubits/profile/profile-cubit.dart';
import 'package:final_app/cubits/profile/prpfile-state.dart';
import 'package:final_app/util/colors.dart';
import 'package:final_app/util/responsive-helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';
  
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with RouteAware {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ModalRoute.of(context)?.addLocalHistoryEntry(LocalHistoryEntry());
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    context.read<ProfileCubit>().loadProfile();
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final XFile? pickedFile = await picker.pickImage(source: source, imageQuality: 80);
      if (context.mounted) Navigator.pop(context);
      if (pickedFile != null) {
        context.read<ProfileCubit>().updateImage(File(pickedFile.path));
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.responsivePadding(context);
    final verticalSpace = ResponsiveHelper.heightPercent(context, 0.025);
    final imageRadius = ResponsiveHelper.responsiveValue(
      context: context, mobile: 50, tablet: 70, desktop: 90);

    return Scaffold(
      drawer: const MyDrawer(),
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Edit Profile'),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: ColorsHelper.darkBlue,
              ),
            );
            context.read<ProfileCubit>().resetSuccess();
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded) {
            return SingleChildScrollView(
              padding: padding,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: verticalSpace),
                    _buildProfilePicture(context, state, imageRadius),
                    SizedBox(height: verticalSpace),

                    CustomTextField(
                      label: "First Name ",
                      hintText: "Enter Your First Name",
                      prefixIcon: Icons.person,
                      initialValue: state.firstName,
                      onChanged: (val) => context.read<ProfileCubit>().updateProfileField(firstName: val),
                    ),
                    SizedBox(height: verticalSpace),

                    CustomTextField(
                      label: "Last Name ",
                      hintText: "Enter Your Last Name",
                      prefixIcon: Icons.person_outline,
                      initialValue: state.lastName,
                      onChanged: (val) => context.read<ProfileCubit>().updateProfileField(lastName: val),
                    ),
                    SizedBox(height: verticalSpace),

                    CustomTextField(
                      label: "Email ",
                      hintText: "Enter Your Email",
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      initialValue: state.email,
                      onChanged: (val) => context.read<ProfileCubit>().updateProfileField(email: val),
                    ),
                    SizedBox(height: verticalSpace * 1.5),

                    SubmitButton(
                      buttonText: 'Submit',
                      isEnabled: state.isButtonEnabled && !state.isLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<ProfileCubit>().saveProfile(
                            firstName: state.firstName,
                            lastName: state.lastName,
                            email: state.email,
                          );
                        }
                      },
                    ),

                    if (state.isLoading)
                      Padding(
                        padding: EdgeInsets.only(top: verticalSpace),
                        child: const CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  ImageProvider _getImageProvider(ProfileLoaded state) {
    if (state.imageFile != null) {
      return FileImage(state.imageFile!);
    }
    if (state.imagePath != null && state.imagePath!.isNotEmpty) {
      return NetworkImage(state.imagePath!);
    }
    return const AssetImage('assets/icons/avatar.png');
  }

  Widget _buildProfilePicture(BuildContext context, ProfileLoaded state, double radius) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showImageOptions(context),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ColorsHelper.darkBlue.withOpacity(0.3), width: 2),
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundImage: _getImageProvider(state),
            //  key: ValueKey(state.imagePath), // Add key to force rebuild
             key: ValueKey(state.imageFile?.path ?? state.imagePath ?? ''),
            ),
          ),
        ),
        SizedBox(height: ResponsiveHelper.heightPercent(context, 0.01)),
        GestureDetector(
          onTap: () => _showImageOptions(context),
          child: Text(
            'Change Photo',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveTextSize(context, 16),
              color: ColorsHelper.darkBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showImageOptions(BuildContext context) {
    final state = context.read<ProfileCubit>().state;
    if (state is! ProfileLoaded) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Profile Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            if (state.imageFile != null || (state.imagePath?.isNotEmpty ?? false))
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ProfileCubit>().removeImage();
                },
              ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: ColorsHelper.darkBlue),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: ColorsHelper.darkBlue),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
