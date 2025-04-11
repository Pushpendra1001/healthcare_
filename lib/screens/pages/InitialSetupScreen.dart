import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_container.dart';

class InitialSetupScreen extends StatefulWidget {
  @override
  _InitialSetupScreenState createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  final _stepsController = TextEditingController(text: '10000');
  final _caloriesController = TextEditingController(text: '2500');
  final _waterController = TextEditingController(text: '2000');
  final _sleepController = TextEditingController(text: '8');
  bool _isLoading = false;

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    _sleepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Your Health Goals'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Let\'s personalize your health targets',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 30),
            _buildTargetField(
              'Daily Steps Target',
              'Recommended: 10,000 steps',
              Icons.directions_walk,
              _stepsController,
              'steps',
              Colors.blue,
            ),
            SizedBox(height: 20),
            _buildTargetField(
              'Daily Calories to Burn',
              'Recommended: 2,500 kcal',
              Icons.local_fire_department,
              _caloriesController,
              'kcal',
              Colors.orange,
            ),
            SizedBox(height: 20),
            _buildTargetField(
              'Daily Water Intake',
              'Recommended: 2,000 ml',
              Icons.water_drop,
              _waterController,
              'ml',
              Colors.blue[300]!,
            ),
            SizedBox(height: 20),
            _buildTargetField(
              'Daily Sleep Duration',
              'Recommended: 8 hours',
              Icons.bedtime,
              _sleepController,
              'hours',
              Colors.purple,
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTargets,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Start Tracking',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetField(
    String title,
    String subtitle,
    IconData icon,
    TextEditingController controller,
    String unit,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            children: [
              Icon(icon, color: color),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              suffix: Text(unit),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTargets() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'dailyStepsTarget': int.parse(_stepsController.text),
        'dailyCaloriesTarget': int.parse(_caloriesController.text),
        'dailyWaterTarget': int.parse(_waterController.text),
        'dailySleepTarget': int.parse(_sleepController.text),
        'setupCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }).catchError((error) {
        
        return FirebaseFirestore.instance.collection('users').doc(userId).set({
          'dailyStepsTarget': int.parse(_stepsController.text),
          'dailyCaloriesTarget': int.parse(_caloriesController.text),
          'dailyWaterTarget': int.parse(_waterController.text),
          'dailySleepTarget': int.parse(_sleepController.text),
          'setupCompleted': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainContainer()),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving targets: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validateInputs() {
    try {
      
      final steps = int.parse(_stepsController.text);
      final calories = int.parse(_caloriesController.text);
      final water = int.parse(_waterController.text);
      final sleep = int.parse(_sleepController.text);
      
      
      if (steps <= 0 || steps > 100000) {
        _showError("Please enter a valid steps target (1-100,000)");
        return false;
      }
      
      if (calories <= 0 || calories > 10000) {
        _showError("Please enter a valid calories target (1-10,000)");
        return false;
      }
      
      if (water <= 0 || water > 5000) {
        _showError("Please enter a valid water target (1-5,000 ml)");
        return false;
      }
      
      if (sleep <= 0 || sleep > 24) {
        _showError("Please enter a valid sleep target (1-24 hours)");
        return false;
      }
      
      return true;
    } catch (e) {
      _showError("Please enter valid numbers for all fields");
      return false;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}