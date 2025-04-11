import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../models/UserTargets.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isEditingPersonalInfo = false;
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              
              _nameController.text = userData['name'] ?? 'User';
              _ageController.text = userData['age']?.toString() ?? '';
              _heightController.text = userData['height']?.toString() ?? '';
              _weightController.text = userData['weight']?.toString() ?? '';
              _bioController.text = userData['bio'] ?? 'Health enthusiast';
              
              final user = {
                'name': userData['name'] ?? 'User',
                'email': userData['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '',
                'joined': userData['createdAt'] != null 
                    ? _formatDate(userData['createdAt'])
                    : 'Recently',
                'bio': userData['bio'] ?? 'Health enthusiast',
                'age': userData['age']?.toString() ?? 'Not set',
                'height': userData['height']?.toString() ?? 'Not set',
                'weight': userData['weight']?.toString() ?? 'Not set',
                'bloodType': userData['bloodType'] ?? 'Not set',
              };
              
              return CustomScrollView(
                slivers: [
                  _buildAppBar(user),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildPersonalInfo(user),
                        _buildTargetsSection(targets),
                        _buildHealthInsightsSection(),
                        _buildActionsSection(context),
                        SizedBox(height: 20),
                        Text(
                          'Health Monitor v1.0',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(Map<String, dynamic> user) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(user['name']),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  user['name'].toString().substring(0, 1),
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                user['email'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Text(
                'Member since ${user['joined']}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            setState(() {
              _isEditingPersonalInfo = !_isEditingPersonalInfo;
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: _signOut,
        ),
      ],
    );
  }

  Widget _buildPersonalInfo(Map<String, dynamic> user) {
    return Container(
      margin: EdgeInsets.all(16),
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
      child: _isEditingPersonalInfo 
          ? _buildEditPersonalInfo() 
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        setState(() {
                          _isEditingPersonalInfo = true;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildInfoItem('Bio', user['bio']),
                Divider(),
                _buildInfoRow('Age', user['age'], 'Height', user['height'] + ' cm'),
                Divider(),
                _buildInfoRow('Weight', user['weight'] + ' kg', 'Blood Type', user['bloodType']),
              ],
            ),
    );
  }

  Widget _buildEditPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Edit Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              icon: Icon(Icons.save),
              label: Text('Save'),
              onPressed: _savePersonalInfo,
            ),
          ],
        ),
        SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: _bioController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Bio',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Blood Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                value: 'A+',
                items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        Expanded(child: _buildInfoItem(label1, value1)),
        SizedBox(width: 20),
        Expanded(child: _buildInfoItem(label2, value2)),
      ],
    );
  }

  Widget _buildTargetsSection(UserTargets targets) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Targets',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
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

  Widget _buildHealthInsightsSection() {
    return Container(
      margin: EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Health Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Full analytics coming soon!'),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  );
                },
                child: Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildInsightCard(
            'Your sleep score is improving',
            'You have been consistently meeting your sleep goals this week. Keep it up!',
            Icons.trending_up,
            Colors.green,
          ),
          SizedBox(height: 12),
          _buildInsightCard(
            'Water intake needs attention',
            'You have been below your hydration goal for the past 3 days.',
            Icons.warning_amber_rounded,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          SizedBox(width: 16),
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
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account & Security',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildActionTile(
            'Data Privacy',
            'Manage how your data is stored and used',
            Icons.shield,
            Colors.blue,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Privacy settings coming soon')),
              );
            },
          ),
          Divider(),
          _buildActionTile(
            'Export Health Data',
            'Download your data in a secure format',
            Icons.cloud_download,
            Colors.green,
            () => _showExportDataDialog(context),
          ),
          Divider(),
          _buildActionTile(
            'Notifications',
            'Configure app alerts and reminders',
            Icons.notifications,
            Colors.orange,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notification settings coming soon')),
              );
            },
          ),
          Divider(),
          _buildActionTile(
            'Sign Out',
            'Log out from your account',
            Icons.logout,
            Colors.red,
            _signOut,
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
      contentPadding: EdgeInsets.zero,
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
  
  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _savePersonalInfo() async {
    try {
      // Validate data
      int? age = _ageController.text.isNotEmpty ? int.tryParse(_ageController.text) : null;
      int? height = _heightController.text.isNotEmpty ? int.tryParse(_heightController.text) : null;
      double? weight = _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null;
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_firebaseService.currentUserId)
          .update({
        'name': _nameController.text,
        'bio': _bioController.text,
        'age': age,
        'height': height,
        'weight': weight,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      setState(() {
        _isEditingPersonalInfo = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
    }
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

  void _showExportDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Health Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select the format for your health data export:'),
            SizedBox(height: 20),
            _buildExportOption(
              'CSV Format',
              'Export as comma-separated values file',
              Icons.description,
              Colors.blue,
              () {
                Navigator.pop(context);
                _simulateDataExport('CSV');
              },
            ),
            SizedBox(height: 12),
            _buildExportOption(
              'JSON Format',
              'Export as structured data file',
              Icons.code,
              Colors.purple,
              () {
                Navigator.pop(context);
                _simulateDataExport('JSON');
              },
            ),
            SizedBox(height: 12),
            _buildExportOption(
              'PDF Report',
              'Export as formatted document',
              Icons.picture_as_pdf,
              Colors.red,
              () {
                Navigator.pop(context);
                _simulateDataExport('PDF');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            SizedBox(width: 12),
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
          ],
        ),
      ),
    );
  }

  void _simulateDataExport(String format) {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Preparing your data export...'),
          ],
        ),
      ),
    );
    
    // Simulate processing time
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // Close the loading dialog
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your health data has been exported as $format'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return DateFormat('MMMM yyyy').format(date);
    }
    return 'Recently';
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