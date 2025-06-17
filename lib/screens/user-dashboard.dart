import 'package:easy_localization/easy_localization.dart';
import 'package:final_app/Helper/app-bar.dart';
import 'package:final_app/Helper/card-ticket.dart';
import 'package:final_app/Widgets/drawer.dart';
import 'package:final_app/models/statistics-model.dart';
import 'package:final_app/services/statistics-service.dart';
import 'package:final_app/util/colors.dart';
import 'package:final_app/util/responsive-helper.dart';
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

          // For daily respond bar chart, prepare data for last 5 years
          final Map<int, double> dailyYearData = {};
          for (var ticket in recentData) {
            final year = DateTime.parse(ticket.createdAt).year;
            dailyYearData.update(year, (value) => value + 1, ifAbsent: () => 1);
          }
          final currentYear = DateTime.now().year;
          final dailyBarData = List.generate(5, (index) {
            final year = currentYear - (4 - index);
            return FlSpot(index.toDouble(), dailyYearData[year]?.toDouble() ?? 0);
          });

          // Calculate proper maxY for daily data with buffer
          double dailyMaxY = 5; // Default minimum
          if (dailyBarData.isNotEmpty) {
            final maxDaily = dailyBarData.map((e) => e.y).reduce((a, b) => a > b ? a : b);
            dailyMaxY = (maxDaily + (maxDaily * 0.2)).clamp(5.0, double.infinity); // Add 20% buffer, minimum 5
          }

          // For annual chart: Generate exactly 5 years of data (current year and previous 4) from annualData
          final fiveYearData = List.generate(5, (index) {
            final year = currentYear - (4 - index);
            return annualData.firstWhere(
              (e) => e.year == year,
              orElse: () => AnnualTicket(year: year, count: 0),
            );
          });

          // Calculate proper maxY for annual data with buffer
          double maxY = 10; // Default minimum
          if (fiveYearData.isNotEmpty) {
            final maxCount = fiveYearData.map((e) => e.count).reduce((a, b) => a > b ? a : b);
            maxY = (maxCount + (maxCount * 0.2)).clamp(5.0, double.infinity); // Add 20% buffer, minimum 5
          }

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
                  childAspectRatio: ResponsiveHelper.responsiveValue(
                    context: context,
                    mobile: 0.95,
                    tablet: 0.9,
                    desktop: 0.85,
                  ),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    StatusCard(
                      icon: Icons.airplane_ticket,
                      title: 'allTickets'.tr(),
                      value: stats.totalTickets.toString(),
                       percentage: stats.totalTickets > 0 ? 100 : 0,
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
                    StatusCard(
                      icon: Icons.airplane_ticket,
                      title: 'resolved-tickets'.tr(),
                      value: stats.openTickets.toString(),
                      percentage: stats.totalTickets > 0
                          ? (stats.openTickets / stats.totalTickets) * 100
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

                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: dailyMaxY,
                            minY: 0,
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
                            ),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();
                                    if (index >= 0 && index < 5) {
                                      final year = currentYear - (4 - index);
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          year.toString(),
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                  interval: 1,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: dailyMaxY > 10 ? (dailyMaxY / 5).ceilToDouble() : 1,
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
                            barGroups: List.generate(5, (index) {
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: dailyBarData[index].y,
                                    color: ColorsHelper.darkBlue,
                                    width: 16,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
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
                                  clipData: FlClipData.all(),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: maxY > 10 ? (maxY / 5).ceilToDouble() : 1,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey.withOpacity(0.2),
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          int index = value.toInt();
                                          if (index >= 0 && index < fiveYearData.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                fiveYearData[index].year.toString(),
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
                                        interval: maxY > 10 ? (maxY / 5).ceilToDouble() : 1,
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
                                        return FlSpot(
                                          entry.key.toDouble(),
                                          entry.value.count.toDouble().clamp(0.0, maxY)
                                        );
                                      }).toList(),
                                      isCurved: true,
                                      curveSmoothness: 0.3,
                                      color: ColorsHelper.darkBlue,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      preventCurveOverShooting: true,
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
                            : Center(child: Text('noAnnualTicketsData'.tr())),
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
