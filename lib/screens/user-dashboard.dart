import 'package:flutter/material.dart';
import 'package:final_app/models/statistics-model.dart';
import 'package:final_app/Helper/app-bar.dart';
import 'package:final_app/Helper/card-ticket.dart';
import 'package:final_app/Widgets/drawer.dart';
import 'package:final_app/services/statistics.dart';

class UserDashboard extends StatefulWidget {
  static const String routeName = "/user-dashboard";
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final UserStatisticsService _statisticsService = UserStatisticsService();
  TicketStatistics? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _statisticsService.fetchStatistics();
      print('Fetched Statistics: $stats');
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error occurred while fetching stats: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load statistics: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: CustomAppBar(
        title: 'Dashboard',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? const Center(child: Text('No statistics available'))
              : GridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    StatusCard(
                      title: 'All Tickets',
                      value: _stats!.totalTickets.toString(),
                      percentage: 100,
                      isLoading: _stats == null,
                    ),
                    StatusCard(
                      title: 'Open Tickets',
                      value: _stats!.openTickets.toString(),
                      percentage: (_stats!.totalTickets == 0)
                          ? 0
                          : ((_stats!.openTickets * 100) /
                                  _stats!.totalTickets)
                              .round(),
                      isLoading: _stats == null,
                    ),
                    StatusCard(
                      title: 'Closed Tickets',
                      value: _stats!.closedTickets.toString(),
                      percentage: (_stats!.totalTickets == 0)
                          ? 0
                          : ((_stats!.closedTickets * 100) /
                                  _stats!.totalTickets)
                              .round(),
                      isLoading: _stats == null,
                    ),
                  ],
                ),
    );
  }
}






