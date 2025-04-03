import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> targets = {
    'dailyStepsTarget': 10000,
    'dailyCaloriesTarget': 2500,
    'dailyWaterTarget': 2000,
    'dailySleepTarget': 8,
  };

  final Map<String, dynamic> user = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'joined': 'April 2025',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            _buildTargetsSection(),
            _buildActionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              user['name'].substring(0, 1),
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            user['name'],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            user['email'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Member since ${user['joined']}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Text(
              'Your Health Targets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildTargetTile(
            'Daily Steps Target',
            '${targets['dailyStepsTarget']} steps',
            Icons.directions_walk,
            Colors.blue,
          ),
          Divider(),
          _buildTargetTile(
            'Daily Calories Target',
            '${targets['dailyCaloriesTarget']} kcal',
            Icons.local_fire_department,
            Colors.orange,
          ),
          Divider(),
          _buildTargetTile(
            'Daily Water Target',
            '${targets['dailyWaterTarget']} ml',
            Icons.water_drop,
            Colors.blue[300]!,
          ),
          Divider(),
          _buildTargetTile(
            'Daily Sleep Target',
            '${targets['dailySleepTarget']} hours',
            Icons.bedtime,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildTargetTile(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(value),
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      trailing: IconButton(
        icon: Icon(Icons.edit, color: Colors.grey),
        onPressed: () {
          
        },
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('Edit Profile'),
                  leading: Icon(Icons.person, color: Colors.blue),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    
                  },
                ),
                Divider(height: 1),
                ListTile(
                  title: Text('Notifications'),
                  leading: Icon(Icons.notifications, color: Colors.orange),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    
                  },
                ),
                Divider(height: 1),
                ListTile(
                  title: Text('Privacy Policy'),
                  leading: Icon(Icons.privacy_tip, color: Colors.green),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    
                  },
                ),
                Divider(height: 1),
                ListTile(
                  title: Text('Sign Out'),
                  leading: Icon(Icons.logout, color: Colors.red),
                  onTap: () {
                    
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              'Health Monitor v1.0',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  void _editTarget(BuildContext context, String targetType) {
    
    
  }

  void _signOut(BuildContext context) {
    
    
  }
}