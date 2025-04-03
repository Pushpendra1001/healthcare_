import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  
  final Map<String, dynamic> healthData = {
    'steps': 7500,
    'calories': 1850,
    'water': 1200,
    'sleep': 6,
  };

  final Map<String, dynamic> targets = {
    'dailyStepsTarget': 10000,
    'dailyCaloriesTarget': 2500,
    'dailyWaterTarget': 2000,
    'dailySleepTarget': 8,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildDailySummary(context),
              _buildActivityCards(context),
              _buildDailyGoals(context),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDataDialog(context),
        icon: Icon(Icons.add_circle_outline),
        label: Text('Add Activity'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM yyyy');
    
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
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
                    'Hello,Vaibhavi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    dateFormat.format(now),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Health',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 28,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Good',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                CircularProgressIndicator(
                  value: 0.75,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  strokeWidth: 10,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDailySummary(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '75% Completed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                Icons.directions_walk,
                '${healthData['steps']}',
                'Steps',
                Colors.white,
              ),
              _buildSummaryItem(
                Icons.local_fire_department,
                '${healthData['calories']}',
                'Calories',
                Colors.white,
              ),
              _buildSummaryItem(
                Icons.water_drop,
                '${healthData['water']}ml',
                'Water',
                Colors.white,
              ),
              _buildSummaryItem(
                Icons.bedtime,
                '${healthData['sleep']}h',
                'Sleep',
                Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCards(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Tracking',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildActivityCard(
                  context,
                  'Steps',
                  Icons.directions_walk,
                  healthData['steps'],
                  targets['dailyStepsTarget'],
                  'steps',
                  Colors.blue,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _buildActivityCard(
                  context,
                  'Calories',
                  Icons.local_fire_department,
                  healthData['calories'],
                  targets['dailyCaloriesTarget'],
                  'kcal',
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildActivityCard(
                  context,
                  'Water',
                  Icons.water_drop,
                  healthData['water'],
                  targets['dailyWaterTarget'],
                  'ml',
                  Colors.blue[300]!,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _buildActivityCard(
                  context,
                  'Sleep',
                  Icons.bedtime,
                  healthData['sleep'],
                  targets['dailySleepTarget'],
                  'hours',
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String title,
    IconData icon,
    int current,
    int target,
    String unit,
    Color color,
  ) {
    final progress = (current / target).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return GestureDetector(
      onTap: () => _showActivityDetails(context, title, current, target, unit, color),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              '$current / $target $unit',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyGoals(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Goals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          _buildGoalCard(
            context,
            'Complete your steps goal',
            '${healthData['steps']} of ${targets['dailyStepsTarget']} steps',
            0.75,
            Colors.blue,
          ),
          SizedBox(height: 15),
          _buildGoalCard(
            context,
            'Drink enough water',
            '${healthData['water']} of ${targets['dailyWaterTarget']} ml',
            0.6,
            Colors.blue[300]!,
          ),
          SizedBox(height: 15),
          _buildGoalCard(
            context,
            'Get enough sleep',
            '${healthData['sleep']} of ${targets['dailySleepTarget']} hours',
            0.75,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    String title,
    String subtitle,
    double progress,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            margin: EdgeInsets.only(right: 15),
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      strokeWidth: 5,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  void _showActivityDetails(
    BuildContext context,
    String activity,
    int current,
    int target,
    String unit,
    Color color,
  ) {
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$activity details coming soon!'),
        backgroundColor: color,
      ),
    );
  }

  void _showAddDataDialog(BuildContext context) {
    final stepsController = TextEditingController();
    final caloriesController = TextEditingController();
    final waterController = TextEditingController();
    final sleepController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Health Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Enter your latest health metrics',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 20),
              _buildInputField(
                controller: stepsController,
                labelText: 'Steps',
                icon: Icons.directions_walk,
                color: Colors.blue,
              ),
              SizedBox(height: 15),
              _buildInputField(
                controller: caloriesController,
                labelText: 'Calories burned',
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
              SizedBox(height: 15),
              _buildInputField(
                controller: waterController,
                labelText: 'Water intake (ml)',
                icon: Icons.water_drop,
                color: Colors.blue[300]!,
              ),
              SizedBox(height: 15),
              _buildInputField(
                controller: sleepController,
                labelText: 'Sleep duration (hours)',
                icon: Icons.bedtime,
                color: Colors.purple,
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required Color color,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color),
        ),
      ),
    );
  }
}