import 'dart:io';
import 'package:final_app/cubits/prpfile-state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:final_app/Helper/app-bar.dart';
import 'package:final_app/Helper/custom-textField.dart';
import 'package:final_app/Helper/Custom-big-button.dart';
import 'package:final_app/Widgets/drawer.dart';
import 'package:final_app/cubits/profile-cubit.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isButtonEnabled = false;
  File? _image;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_checkFields);
    _lastNameController.addListener(_checkFields);
    _emailController.addListener(_checkFields);
  }

  void _checkFields() {
    setState(() {
      _isButtonEnabled = _firstNameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final pickedImage = File(pickedFile.path);
      setState(() {
        _image = pickedImage;
      });

   
      context.read<ProfileCubit>().updateProfileImage(pickedImage);
    }
  }

  void _submitForm() {
    if (_isButtonEnabled) {
      final profileCubit = context.read<ProfileCubit>();
      profileCubit.updateProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        imageFile: _image, 
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: CustomAppBar(title: 'Edit Profile'),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded) {
          
            if (_firstNameController.text.isEmpty) {
              _firstNameController.text = state.firstName;
              _lastNameController.text = state.lastName;
              _emailController.text = state.email;
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    _buildProfilePicture(state.imagePath),
                    SizedBox(height: 20),
                    Form(
                      child: Column(
                        children: [
                          CustomTextField(
                            label: "First Name",
                            controller: _firstNameController,
                            onChanged: (_) {},
                          ),
                          SizedBox(height: 15),
                          CustomTextField(
                            label: "Last Name",
                            controller: _lastNameController,
                            onChanged: (_) {},
                          ),
                          SizedBox(height: 15),
                          CustomTextField(
                            label: "Email",
                            controller: _emailController,
                            onChanged: (_) {},
                          ),
                          SizedBox(height: 25),
                          SubmitButton(
                            buttonText: 'Submit',
                            isEnabled: _isButtonEnabled,
                            onPressed: _submitForm,
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildProfilePicture(String? imagePath) {
    ImageProvider imageProvider;

    if (_image != null) {
      imageProvider = FileImage(_image!);
    } else if (imagePath != null && imagePath.isNotEmpty) {
      imageProvider = NetworkImage(imagePath);
    } else {
      imageProvider = AssetImage('assets/icons/avatar.png');
    }

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImageOptions,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: imageProvider,
            ),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
            child: Text(
              'Change Photo',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            if (_image != null ||
                (context.read<ProfileCubit>().state is ProfileLoaded &&
                    (context.read<ProfileCubit>().state as ProfileLoaded).imagePath!.isNotEmpty))
              ListTile(
                leading: Icon(Icons.delete, color: Color(0xFFFF4C51)),
                title: Text('Remove Photo', style: TextStyle(color: Color(0xFFFF4C51))),
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
          ],
        );
      },
    );
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
    context.read<ProfileCubit>().updateProfileImage(File(''));
  }
}



