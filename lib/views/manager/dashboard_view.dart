import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/database_service.dart';
import '../../../models/order_model.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final DatabaseService _dbService = DatabaseService();

  List<OrderModel> _filterTodayOrders(List<OrderModel> orders) {
    final now = DateTime.now();
    return orders.where((o) =>
        o.createdAt.year == now.year &&
        o.createdAt.month == now.month &&
        o.createdAt.day == now.day).toList();
  }

  // Calculates revenue per hour between 8:00 AM and 10:00 PM (22)
  Map<int, double> _calculateHourlyRevenue(List<OrderModel> todayOrders) {
    Map<int, double> hourly = {for (var i = 8; i <= 22; i++) i: 0.0};
    for (var order in todayOrders) {
      final hour = order.createdAt.hour;
      if (hour >= 8 && hour <= 22) {
        hourly[hour] = (hourly[hour] ?? 0) + order.totalAmount;
      }
    }
    return hourly;
  }

  // Gets top selling items
  List<MapEntry<String, int>> _getTopSellingItems(List<OrderModel> todayOrders) {
    Map<String, int> itemCounts = {};
    for (var order in todayOrders) {
      for (var item in order.items) {
        itemCounts[item.name] = (itemCounts[item.name] ?? 0) + item.quantity;
      }
    }
    var sorted = itemCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList(); // Top 5
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paleYellow,
      appBar: AppBar(
        title: const Text('Live Sales Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.darkRed,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: _dbService.getPaidOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          }

          final allOrders = snapshot.data ?? [];
          final todayOrders = _filterTodayOrders(allOrders);
          
          final double todayRevenue = todayOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
          final int totalOrders = todayOrders.length;
          final hourlyRevenue = _calculateHourlyRevenue(todayOrders);
          final topSelling = _getTopSellingItems(todayOrders);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // KPI Cards Row
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        title: "Today's Revenue",
                        value: "RM ${todayRevenue.toStringAsFixed(2)}", 
                        icon: Icons.monetization_on_rounded,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildKpiCard(
                        title: "Total Orders",
                        value: "$totalOrders", 
                        icon: Icons.receipt_long_rounded,
                        color: AppTheme.darkRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Live Sales Chart Configuration
                const Text('Sales Trend (Today)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  padding: const EdgeInsets.only(top: 24, left: 16, right: 24, bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: todayOrders.isEmpty 
                    ? const Center(child: Text('No sales data for today yet.', style: TextStyle(color: Colors.grey)))
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (hourlyRevenue.values.fold(0.0, (m, v) => v > m ? v : m) * 1.2).clamp(100.0, double.infinity),
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value % 2 != 0) return const SizedBox.shrink(); // Show every 2 hours
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      '${value.toInt()}:00', 
                                      style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0) return const SizedBox.shrink();
                                  return Text(NumberFormat.compact().format(value), style: const TextStyle(color: Colors.grey, fontSize: 10));
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 50,
                            getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: hourlyRevenue.entries.map((entry) {
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value,
                                  color: AppTheme.primaryOrange,
                                  width: 12,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                ),
                
                const SizedBox(height: 30),

                // Best Selling Items 
                const Text('Top Selling Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: topSelling.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: Text('No items sold today yet.', style: TextStyle(color: Colors.grey))),
                      )
                    : ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: topSelling.length, 
                        separatorBuilder: (context, index) => Divider(color: Colors.grey.withOpacity(0.2), height: 1),
                        itemBuilder: (context, index) {
                          final item = topSelling[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.paleYellow,
                              child: Text('#${index + 1}', style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
                            ),
                            title: Text(item.key, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.darkGrey)),
                            trailing: Text('${item.value} Sold', style: const TextStyle(color: AppTheme.darkRed, fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
                ),
                const SizedBox(height: 30), // Bottom padding
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}
