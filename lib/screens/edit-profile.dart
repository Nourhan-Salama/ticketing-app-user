//correct
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:final_app/Helper/Custom-big-button.dart';
import 'package:final_app/Helper/app-bar.dart';
import 'package:final_app/Helper/custom-textField.dart';
import 'package:final_app/Widgets/drawer.dart';
import 'package:final_app/cubits/profile-cubit.dart';
import 'package:final_app/cubits/prpfile-state.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Loading is now handled in cubit constructor
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        context.read<ProfileCubit>().updateImage(File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: CustomAppBar(title: 'Edit Profile'),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded && state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Use existing loaded state or create default one
          final loadedState = state is ProfileLoaded 
              ? state 
              : ProfileLoaded(
                  firstName: '',
                  lastName: '',
                  email: '',
                  imagePath: '',
                );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfilePicture(context, loadedState.imageFile, loadedState.imagePath ?? ''),
                  const SizedBox(height: 20),

                  CustomTextField(
                    successText: loadedState.firstNameSuccess,
                    label: "First Name",
                    hintText: "Enter Your First Name",
                    prefixIcon: Icons.person,
                    errorText: loadedState.firstNameError,
                    controller: context.read<ProfileCubit>().firstNameController,
                    onChanged: (_) {
                      context.read<ProfileCubit>().validateFields();
                      _formKey.currentState?.validate();
                    },
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    successText: loadedState.lastNameSuccess,
                    label: "Last Name",
                    hintText: "Enter Your Last Name",
                    prefixIcon: Icons.person_outline,
                    errorText: loadedState.lastNameError,
                    controller: context.read<ProfileCubit>().lastNameController,
                    onChanged: (_) {
                      context.read<ProfileCubit>().validateFields();
                      _formKey.currentState?.validate();
                    },
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    successText: loadedState.emailSuccess,
                    label: "Email",
                    hintText: "Enter Your Email",
                    prefixIcon: Icons.email,
                    errorText: loadedState.emailError,
                    controller: context.read<ProfileCubit>().emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) {
                      context.read<ProfileCubit>().validateFields();
                      _formKey.currentState?.validate();
                    },
                  ),
                  const SizedBox(height: 30),

                  SubmitButton(
                    buttonText: 'Submit',
                    isEnabled: loadedState.isButtonEnabled && !loadedState.isLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<ProfileCubit>().saveProfile();
                      }
                    },
                  ),

                  if (loadedState.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfilePicture(BuildContext context, File? file, String imagePath) {
    final ImageProvider imageProvider = file != null
        ? FileImage(file)
        : (imagePath.isNotEmpty
            ? FileImage(File(imagePath))
            : const AssetImage('assets/icons/avatar.png')) as ImageProvider;

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showImageOptions(context),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: imageProvider,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showImageOptions(context),
            child: const Text(
              'Change Photo',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageOptions(BuildContext context) {
    final state = context.read<ProfileCubit>().state;
    if (state is! ProfileLoaded) return;

    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          if (state.imageFile != null || (state.imagePath?.isNotEmpty ?? false))
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                context.read<ProfileCubit>().updateImage(null);
              },
            ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a photo'),
            onTap: () async {
              Navigator.pop(context);
              await _pickImage(context, ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () async {
              Navigator.pop(context);
              await _pickImage(context, ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }
}