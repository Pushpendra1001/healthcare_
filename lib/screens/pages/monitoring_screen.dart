import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonitoringScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Health Monitoring'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Steps'),
              Tab(text: 'Calories'),
              Tab(text: 'Water'),
              Tab(text: 'Sleep'),
            ],
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
        ),
        body: TabBarView(
          children: [
            _buildMonitoringTab('Steps', 10000, Colors.blue, context),
            _buildMonitoringTab('Calories', 2500, Colors.orange, context),
            _buildMonitoringTab('Water', 2000, Colors.blue[300]!, context),
            _buildMonitoringTab('Sleep', 8, Colors.purple, context),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringTab(String type, int target, Color color, BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly $type',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          _buildWeeklyChart(color),
          SizedBox(height: 30),
          Text(
            'Monthly Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          _buildMonthlyStats(type, target, color),
          SizedBox(height: 20),
          _buildStatsCards(type, color),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(Color color) {
    return Container(
      height: 250,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300],
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  String text = '';
                  switch (value.toInt()) {
                    case 0:
                      text = 'Mon';
                      break;
                    case 1:
                      text = 'Tue';
                      break;
                    case 2:
                      text = 'Wed';
                      break;
                    case 3:
                      text = 'Thu';
                      break;
                    case 4:
                      text = 'Fri';
                      break;
                    case 5:
                      text = 'Sat';
                      break;
                    case 6:
                      text = 'Sun';
                      break;
                  }
                  return Text(
                    text,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 3),
                FlSpot(1, 2),
                FlSpot(2, 5),
                FlSpot(3, 3.1),
                FlSpot(4, 4),
                FlSpot(5, 3),
                FlSpot(6, 4),
              ],
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStats(String type, int target, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatColumn('Total', '45,345', type),
              _buildStatColumn('Average', '3,023', 'per day'),
              _buildStatColumn('Best', '5,412', 'in a day'),
            ],
          ),
          SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.75,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          SizedBox(height: 8),
          Text(
            '75% of monthly goal completed',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String title, String value, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(String type, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Breakdown',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 7,
          itemBuilder: (context, index) {
            final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
            final values = [3450, 2890, 5120, 3100, 4200, 3000, 4300];
            
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        days[index],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'April ${index + 1}, 2023',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${values[index]}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}