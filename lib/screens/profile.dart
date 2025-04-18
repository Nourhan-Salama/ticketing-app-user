import 'package:final_app/Helper/app-bar.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
 static const routName = '/profile';
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: CustomAppBar(
      title:'Profile'),
    );
  }
}