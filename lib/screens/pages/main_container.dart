import 'package:flutter/material.dart';
import 'package:healthcare_app/services/firebase_service.dart';
import 'home_screen.dart';
import 'monitoring_screen.dart';
import 'profile_screen.dart';

class MainContainer extends StatefulWidget {
  @override
  _MainContainerState createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    HomeScreen(),
    MonitoringScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    
    
    FirebaseService().checkAndSetupTodayData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Monitor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}