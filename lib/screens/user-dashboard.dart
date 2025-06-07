import 'package:easy_localization/easy_localization.dart';
import 'package:final_app/Helper/app-bar.dart';
import 'package:final_app/Helper/card-ticket.dart';
import 'package:final_app/Widgets/drawer.dart';
import 'package:final_app/models/statistics-model.dart';
import 'package:final_app/services/statistics-service.dart';
import 'package:final_app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class UserDashboard extends StatefulWidget {
  static const String routeName = "/user-dashboard";
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final StatisticsService _statisticsService = StatisticsService();
  late Future<TicketStatistics> _statisticsFuture;

  @override
  void initState() {
    super.initState();
    _statisticsFuture = _statisticsService.getTechnicianStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: CustomAppBar(title: 'dashboard'.tr()),
      body: FutureBuilder<TicketStatistics>(
        future: _statisticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('noDataAvailable').tr());
          }

          final stats = snapshot.data!;
          final annualData = stats.annualTicketsAverage;
          final recentData = stats.recentTickets;

          // Process recent data by year
          final Map<int, double> yearDataMap = {};
          for (var ticket in recentData) {
            final year = DateTime.parse(ticket.createdAt).year;
            yearDataMap.update(year, (value) => value + ticket.status.toDouble(),
                ifAbsent: () => ticket.status.toDouble());
          }

          // Generate exactly 5 years of data (current year and previous 4)
          final currentYear = DateTime.now().year;
          final fiveYearData = List.generate(5, (index) {
            final year = currentYear - (4 - index);
            final existingData = annualData.firstWhere(
              (e) => e.year == year,
              orElse: () => AnnualTicket(year: year, count: 0),
            );
            return AnnualTicket(
              year: year,
              count: yearDataMap[year]?.toInt() ?? existingData.count,
            );
          });

          double maxY = fiveYearData.isNotEmpty
              ? fiveYearData.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble() + 1
              : 10;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Cards
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.85,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    StatusCard(
                      icon: Icons.airplane_ticket,
                      title: 'allTickets'.tr(),
                      value: stats.totalTickets.toString(),
                      percentage: stats.totalTickets > 0
                          ? (stats.totalTickets / stats.totalTickets) * 100
                          : 0,
                    ),
                    StatusCard(
                      icon: Icons.airplane_ticket,
                      title: 'inProgress'.tr(),
                      value: stats.inProcessingTickets.toString(),
                      percentage: stats.totalTickets > 0
                          ? (stats.inProcessingTickets / stats.totalTickets) * 100
                          : 0,
                    ),
                    StatusCard(
                      icon: Icons.airplane_ticket,
                      title: 'closedTickets'.tr(),
                      value: stats.closedTickets.toString(),
                      percentage: stats.totalTickets > 0
                          ? (stats.closedTickets / stats.totalTickets) * 100
                          : 0,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Daily Respond Bar Chart
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'dailyRespond'.tr(),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Center(child: Text('dailyChartNotAvailableForYearlyGrouping').tr()), // رسالة توضيحية بديلة
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Annual Tickets Average Line Chart
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'annualTicketsAverage'.tr(),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: fiveYearData.isNotEmpty
                            ? LineChart(
                                LineChartData(
                                  minX: 0,
                                  maxX: (fiveYearData.length - 1).toDouble(),
                                  minY: 0,
                                  maxY: maxY,
                                  gridData: const FlGridData(show: false),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() < fiveYearData.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                fiveYearData[value.toInt()].year.toString(),
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: maxY > 5 ? 2 : 1,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: fiveYearData.asMap().entries.map((entry) {
                                        return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
                                      }).toList(),
                                      isCurved: true,
                                      curveSmoothness: 0.3,
                                      color: ColorsHelper.darkBlue,
                                      barWidth: 4,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: ColorsHelper.darkBlue,
                                            strokeWidth: 2,
                                            strokeColor: Colors.white,
                                          );
                                        },
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.withOpacity(0.3),
                                            Colors.blue.withOpacity(0.1),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Center(child: Text('noAnnualTicketsData').tr()),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:final_app/models/statistics-model.dart';
// import 'package:final_app/Helper/app-bar.dart';
// import 'package:final_app/Helper/card-ticket.dart';
// import 'package:final_app/Widgets/drawer.dart';
// import 'package:final_app/services/statistics.dart';

// class UserDashboard extends StatefulWidget {
//   static const String routeName = "/user-dashboard";
//   const UserDashboard({super.key});

//   @override
//   State<UserDashboard> createState() => _UserDashboardState();
// }

// class _UserDashboardState extends State<UserDashboard> {
//   final UserStatisticsService _statisticsService = UserStatisticsService();
//   TicketStatistics? _stats;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadStatistics();
//   }

//   Future<void> _loadStatistics() async {
//     try {
//       final stats = await _statisticsService.fetchStatistics();
//       print('Fetched Statistics: $stats');
//       setState(() {
//         _stats = stats;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error occurred while fetching stats: $e');
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load statistics: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: const MyDrawer(),
//       appBar: CustomAppBar(
//         title: 'dashboard'.tr(),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _stats == null
//               ? const Center(child: Text('No statistics available'))
//               : GridView.count(
//                   padding: const EdgeInsets.all(16),
//                   crossAxisCount: 2,
//                   childAspectRatio: 0.85,
//                   mainAxisSpacing: 12,
//                   crossAxisSpacing: 12,
//                   children: [
//                     StatusCard(
//                       title: 'allTickets'.tr(),
//                       value: _stats!.totalTickets.toString(),
//                       percentage: 100,
//                       isLoading: _stats == null,
//                     ),
//                     StatusCard(
//                       title: 'openTickets'.tr(),
//                       value: _stats!.openTickets.toString(),
//                       percentage: (_stats!.totalTickets == 0)
//                           ? 0
//                           : ((_stats!.openTickets * 100) /
//                                   _stats!.totalTickets)
//                               .round(),
//                       isLoading: _stats == null,
//                     ),
//                     StatusCard(
//                       title: 'closedTickets'.tr(),
//                       value: _stats!.closedTickets.toString(),
//                       percentage: (_stats!.totalTickets == 0)
//                           ? 0
//                           : ((_stats!.closedTickets * 100) /
//                                   _stats!.totalTickets)
//                               .round(),
//                       isLoading: _stats == null,
//                     ),
//                   ],
//                 ),
//     );
//   }
// }






