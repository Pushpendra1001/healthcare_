import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../models/HealthData.dart';
import '../../models/UserTargets.dart';

class MonitoringScreen extends StatefulWidget {
  @override
  _MonitoringScreenState createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  
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
        body: StreamBuilder<UserTargets>(
          stream: _firebaseService.getUserTargets(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error loading targets'));
            }
            
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final targets = snapshot.data!;
            
            return TabBarView(
              children: [
                _buildDataMonitoringTab('Steps', targets.dailyStepsTarget, Colors.blue),
                _buildDataMonitoringTab('Calories', targets.dailyCaloriesTarget, Colors.orange),
                _buildDataMonitoringTab('Water', targets.dailyWaterTarget, Colors.blue[300]!),
                _buildDataMonitoringTab('Sleep', targets.dailySleepTarget, Colors.purple),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDataMonitoringTab(String type, int target, Color color) {
    final typeKey = type.toLowerCase();
    
    return FutureBuilder<List<HealthData>>(
      future: _firebaseService.getWeeklyHealthData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error loading data'));
        }
        
        final weeklyData = snapshot.data ?? [];
        
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
              _buildWeeklyChart(weeklyData, typeKey, target, color),
              SizedBox(height: 30),
              Text(
                'Weekly Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildWeeklyStats(weeklyData, typeKey, target, color),
              SizedBox(height: 20),
              _buildDailyStats(weeklyData, typeKey, target, color),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyChart(List<HealthData> weekData, String type, int target, Color color) {
    // Map type to the correct field
    int Function(HealthData) getValue;
    switch (type) {
      case 'steps':
        getValue = (data) => data.steps;
        break;
      case 'calories':
        getValue = (data) => data.calories;
        break;
      case 'water':
        getValue = (data) => data.water;
        break;
      case 'sleep':
        getValue = (data) => data.sleep;
        break;
      default:
        getValue = (data) => 0;
    }

    final spots = weekData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final value = getValue(entry.value).toDouble();
      return FlSpot(index, value);
    }).toList();

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
            horizontalInterval: target / 5,
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
                  if (value < 0 || value >= weekData.length) return Text('');
                  final date = weekData[value.toInt()].date;
                  final dayName = DateFormat('E').format(date);
                  return Text(
                    dayName,
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
          minX: 0,
          maxX: weekData.length - 1.0,
          minY: 0,
          maxY: target * 1.2,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.1),
              ),
            ),
            // Add a target line
            LineChartBarData(
              spots: [
                FlSpot(0, target.toDouble()),
                FlSpot(6, target.toDouble()),
              ],
              isCurved: false,
              color: Colors.grey[400]!,
              barWidth: 1,
              dotData: FlDotData(show: false),
              dashArray: [5, 5],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStats(List<HealthData> weekData, String type, int target, Color color) {
    // Map type to the correct field
    int Function(HealthData) getValue;
    switch (type) {
      case 'steps':
        getValue = (data) => data.steps;
        break;
      case 'calories':
        getValue = (data) => data.calories;
        break;
      case 'water':
        getValue = (data) => data.water;
        break;
      case 'sleep':
        getValue = (data) => data.sleep;
        break;
      default:
        getValue = (data) => 0;
    }

    final total = weekData.fold(0, (sum, data) => sum + getValue(data));
    final average = weekData.isEmpty ? 0 : total ~/ weekData.length;
    final best = weekData.isEmpty ? 0 : weekData.map(getValue).reduce((a, b) => a > b ? a : b);
    final progress = weekData.isEmpty ? 0.0 : total / (target * 7);

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
              _buildStatColumn('Total', '$total', type),
              _buildStatColumn('Average', '$average', 'per day'),
              _buildStatColumn('Best', '$best', 'in a day'),
            ],
          ),
          SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% of weekly goal completed',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStats(List<HealthData> weekData, String type, int target, Color color) {
    // Map type to the correct field
    int Function(HealthData) getValue;
    String suffix;
    
    switch (type) {
      case 'steps':
        getValue = (data) => data.steps;
        suffix = 'steps';
        break;
      case 'calories':
        getValue = (data) => data.calories;
        suffix = 'kcal';
        break;
      case 'water':
        getValue = (data) => data.water;
        suffix = 'ml';
        break;
      case 'sleep':
        getValue = (data) => data.sleep;
        suffix = 'hours';
        break;
      default:
        getValue = (data) => 0;
        suffix = '';
    }

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
          itemCount: weekData.length,
          itemBuilder: (context, index) {
            final data = weekData[index];
            final value = getValue(data);
            final progress = value / target;
            final date = data.date;
            final dayName = DateFormat('EEEE').format(date);
            final dateStr = DateFormat('MMM d, yyyy').format(date);
            
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            dateStr,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$value $suffix',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toInt()}% of daily goal',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
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
}