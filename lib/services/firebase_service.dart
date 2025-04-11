import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/UserTargets.dart';
import '../models/HealthData.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get user targets stream
  Stream<UserTargets> getUserTargets() {
    final String uid = currentUserId ?? '';
    if (uid.isEmpty) throw Exception('No user logged in');

    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) throw Exception('User document not found');
          
          final data = doc.data() ?? {};
          return UserTargets(
            userId: uid,
            dailyStepsTarget: data['dailyStepsTarget'] ?? 10000,
            dailyCaloriesTarget: data['dailyCaloriesTarget'] ?? 2500,
            dailyWaterTarget: data['dailyWaterTarget'] ?? 2000,
            dailySleepTarget: data['dailySleepTarget'] ?? 8,
          );
        });
  }

  // Get today's health data
  Stream<HealthData> getTodayHealthData() {
    final String uid = currentUserId ?? '';
    if (uid.isEmpty) throw Exception('No user logged in');
    
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('health_data')
        .doc(dateStr)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            // Create default data
            return HealthData(
              id: dateStr,
              userId: uid,
              date: today,
            );
          }
          
          return HealthData.fromJson({
            ...doc.data()!,
            'id': doc.id,
          });
        });
  }

  // Get weekly health data for charts
  Future<List<HealthData>> getWeeklyHealthData() async {
    final String uid = currentUserId ?? '';
    if (uid.isEmpty) throw Exception('No user logged in');
    
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final endDate = startDate.add(Duration(days: 7));

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('health_data')
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThan: endDate.toIso8601String())
        .get();

    if (snapshot.docs.isEmpty) {
      return List.generate(7, (index) {
        final day = startDate.add(Duration(days: index));
        return HealthData(
          id: '${day.year}-${day.month}-${day.day}',
          userId: uid,
          date: day,
        );
      });
    }

    // Convert snapshots to HealthData objects
    final healthDataList = snapshot.docs.map((doc) => 
      HealthData.fromJson({...doc.data(), 'id': doc.id})
    ).toList();
    
    // Fill in any missing days
    final dataMap = {for (var data in healthDataList) 
      '${data.date.year}-${data.date.month}-${data.date.day}': data};
    
    return List.generate(7, (index) {
      final day = startDate.add(Duration(days: index));
      final dateKey = '${day.year}-${day.month}-${day.day}';
      
      return dataMap[dateKey] ?? HealthData(
        id: dateKey,
        userId: uid,
        date: day,
      );
    });
  }

  // Update health data values
  Future<void> updateHealthData({
    required String type,
    required int value,
  }) async {
    final String uid = currentUserId ?? '';
    if (uid.isEmpty) throw Exception('No user logged in');
    
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('health_data')
        .doc(dateStr)
        .set({
          'userId': uid,
          'date': today.toIso8601String(),
          type: value,
        }, SetOptions(merge: true));
  }

  // Sign out user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}