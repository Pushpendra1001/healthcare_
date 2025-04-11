import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';
import '../../models/UserTargets.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: StreamBuilder<UserTargets>(
        stream: _firebaseService.getUserTargets(),
        builder: (context, targetsSnapshot) {
          if (targetsSnapshot.hasError) {
            return Center(child: Text('Error loading data'));
          }
          
          if (!targetsSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          
          final targets = targetsSnapshot.data!;
          
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(_firebaseService.currentUserId)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.hasError) {
                return Center(child: Text('Error loading user data'));
              }
              
              if (!userSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              
              final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
              
              final user = {
                'name': userData['name'] ?? 'User',
                'email': userData['email'] ?? '',
                'joined': userData['createdAt'] != null 
                    ? _formatDate(userData['createdAt'])
                    : 'Recently',
              };
              
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileHeader(context, user),
                    _buildTargetsSection(targets),
                    _buildActionsSection(context),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.month}/${date.year}';
    }
    return 'Recently';
  }

  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> user) {
    return Container(
      padding: EdgeInsets.all(24),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              user['name'].toString().substring(0, 1),
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

  Widget _buildTargetsSection(UserTargets targets) {
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
            '${targets.dailyStepsTarget} steps',
            Icons.directions_walk,
            Colors.blue,
            () => _editTarget(context, 'dailyStepsTarget', targets.dailyStepsTarget),
          ),
          Divider(),
          _buildTargetTile(
            'Daily Calories Target',
            '${targets.dailyCaloriesTarget} kcal',
            Icons.local_fire_department,
            Colors.orange,
            () => _editTarget(context, 'dailyCaloriesTarget', targets.dailyCaloriesTarget),
          ),
          Divider(),
          _buildTargetTile(
            'Daily Water Target',
            '${targets.dailyWaterTarget} ml',
            Icons.water_drop,
            Colors.blue[300]!,
            () => _editTarget(context, 'dailyWaterTarget', targets.dailyWaterTarget),
          ),
          Divider(),
          _buildTargetTile(
            'Daily Sleep Target',
            '${targets.dailySleepTarget} hours',
            Icons.bedtime,
            Colors.purple,
            () => _editTarget(context, 'dailySleepTarget', targets.dailySleepTarget),
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
    VoidCallback onTap,
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
        onPressed: onTap,
      ),
    );
  }

  void _editTarget(BuildContext context, String targetField, int currentValue) {
    final controller = TextEditingController(text: currentValue.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Target'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Enter new value',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final newValue = int.parse(controller.text);
                if (newValue <= 0) throw Exception('Value must be positive');
                
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_firebaseService.currentUserId)
                    .update({targetField: newValue});
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Target updated successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid number')),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Coming soon')),
                    );
                  },
                ),
                Divider(height: 1),
                ListTile(
                  title: Text('Notifications'),
                  leading: Icon(Icons.notifications, color: Colors.orange),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Coming soon')),
                    );
                  },
                ),
                Divider(height: 1),
                ListTile(
                  title: Text('Privacy Policy'),
                  leading: Icon(Icons.privacy_tip, color: Colors.green),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Coming soon')),
                    );
                  },
                ),
                Divider(height: 1),
                ListTile(
                  title: Text('Sign Out'),
                  leading: Icon(Icons.logout, color: Colors.red),
                  onTap: _signOut,
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

  void _signOut() async {
    try {
      await _firebaseService.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SignInScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out')),
      );
    }
  }
}