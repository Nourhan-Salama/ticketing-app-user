import 'package:final_app/Helper/app-bar.dart';
import 'package:final_app/Helper/card-ticket.dart';
import 'package:final_app/Widgets/drawer.dart';
import 'package:flutter/material.dart';

class UserDashboard extends StatefulWidget {
   static const String routeName = "/user-dashboard"; 
  UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboarState();
}

class _UserDashboarState extends State<UserDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: CustomAppBar(
        title: 'Dashboard',
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: const [
          StatusCard(
            title: 'All Tickets',
            value: '7',
            percentage: 100,
          ),
          StatusCard(
            title: 'Open Tickets',
            value: '3',
            percentage: 30,
          ),
          StatusCard(
            title: 'Closed Tickets',
            value: '4',
            percentage: 70,
          ),
        ],
      ),
    );
  }
}
