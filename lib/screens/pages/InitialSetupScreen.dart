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
  final _formKey = GlobalKey<FormState>();

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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome! Let\'s set your daily health targets.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildTargetField(
                'Daily Steps Goal',
                'How many steps do you aim to walk each day?',
                Icons.directions_walk,
                _stepsController,
                'steps',
                Colors.blue,
              ),
              SizedBox(height: 20),
              _buildTargetField(
                'Calorie Intake Target',
                'What\'s your daily calorie intake goal?',
                Icons.local_fire_department,
                _caloriesController,
                'calories',
                Colors.orange,
              ),
              SizedBox(height: 20),
              _buildTargetField(
                'Daily Water Intake',
                'How much water do you plan to drink daily?',
                Icons.water_drop,
                _waterController,
                'ml',
                Colors.blue[300]!,
              ),
              SizedBox(height: 20),
              _buildTargetField(
                'Sleep Duration',
                'How many hours do you aim to sleep each night?',
                Icons.bedtime,
                _sleepController,
                'hours',
                Colors.purple,
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTargets,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Save & Continue', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
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
          TextFormField(
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a value';
              }
              try {
                int intValue = int.parse(value);
                if (intValue <= 0) {
                  return 'Please enter a value greater than 0';
                }
              } catch (e) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveTargets() async {
    
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      
      
      final Map<String, dynamic> userData = {
        'dailyStepsTarget': int.parse(_stepsController.text),
        'dailyCaloriesTarget': int.parse(_caloriesController.text),
        'dailyWaterTarget': int.parse(_waterController.text),
        'dailySleepTarget': int.parse(_sleepController.text),
        'setupCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(userData, SetOptions(merge: true));
      
      if (mounted) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Setup completed successfully!'))
        );
        
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainContainer()),
        );
      }
    } catch (e) {
      print("Error saving targets: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Unable to save your goals. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}