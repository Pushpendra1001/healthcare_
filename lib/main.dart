import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthcare_app/screens/pages/main_container.dart';
import 'package:healthcare_app/screens/pages/InitialSetupScreen.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health Monitor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: AuthStateManager(), 
    );
  }
}


class AuthStateManager extends StatefulWidget {
  @override
  _AuthStateManagerState createState() => _AuthStateManagerState();
}

class _AuthStateManagerState extends State<AuthStateManager> {
  User? _currentUser;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print("Auth state changed: user ${user != null ? 'signed in' : 'signed out'}");
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    
    if (_isLoading) {
      return SplashScreen();
    }
    
    
    if (_currentUser == null) {
      return SignInScreen();
    }
    
    
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).get(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        }
        
        
        if (snapshot.hasError) {
          print("Error loading user data: ${snapshot.error}");
          return ErrorScreen(
            message: "Error loading user data: ${snapshot.error}",
            onRetry: () async {
              await FirebaseAuth.instance.signOut();
              setState(() {
                _isLoading = true;
              });
            },
          );
        }
        
        
        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        
        
        if (userData != null && userData.containsKey('dailyStepsTarget')) {
          print("User has completed setup, going to MainContainer");
          return MainContainer();
        } else {
          print("User needs to complete setup");
          return InitialSetupScreen();
        }
      },
    );
  }
}


class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/app_icon.png', height: 100),
            SizedBox(height: 20),
            Text(
              'Health Monitor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}


class ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  
  const ErrorScreen({
    Key? key, 
    required this.message, 
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('Sign Out and Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
