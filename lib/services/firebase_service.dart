import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/UserTargets.dart';
import '../models/HealthData.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  String? get currentUserId => _auth.currentUser?.uid;

  
  Stream<UserTargets> getUserTargets() {
    final String uid = currentUserId ?? '';
    if (uid.isEmpty) throw Exception('No user logged in');

    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) {
            
            return UserTargets(
              userId: uid,
              dailyStepsTarget: 10000,
              dailyCaloriesTarget: 2500,
              dailyWaterTarget: 2000,
              dailySleepTarget: 8,
            );
          }
          
          
          final data = doc.data()!;
          return UserTargets(
            userId: uid,
            dailyStepsTarget: data['dailyStepsTarget'] ?? 10000,
            dailyCaloriesTarget: data['dailyCaloriesTarget'] ?? 2500,
            dailyWaterTarget: data['dailyWaterTarget'] ?? 2000,
            dailySleepTarget: data['dailySleepTarget'] ?? 8,
          );
        });
  }

  
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
          if (!doc.exists || doc.data() == null) {
            
            return HealthData(
              id: dateStr,
              userId: uid,
              date: today,
            );
          }
          
          try {
            
            final data = doc.data()!;
            return HealthData(
              id: doc.id,
              userId: uid,
              steps: data['steps'] ?? 0,
              calories: data['calories'] ?? 0,
              water: data['water'] ?? 0,
              sleep: data['sleep'] ?? 0,
              date: data['date'] != null 
                  ? (data['date'] is Timestamp 
                      ? (data['date'] as Timestamp).toDate()
                      : DateTime.parse(data['date'].toString())) 
                  : today,
            );
          } catch (e) {
            print("Error parsing health data: $e");
            
            return HealthData(
              id: dateStr,
              userId: uid,
              date: today,
            );
          }
        });
  }

  
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

    
    final healthDataList = snapshot.docs.map((doc) => 
      HealthData.fromJson({...doc.data(), 'id': doc.id})
    ).toList();
    
    
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

  
  Future<void> addHealthData({
    required String type,
    required int value,
  }) async {
    final String uid = currentUserId ?? '';
    if (uid.isEmpty) throw Exception('No user logged in');
    
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
    
    
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('health_data')
        .doc(dateStr);
        
    final docSnapshot = await docRef.get();
    
    if (docSnapshot.exists) {
      
      final data = docSnapshot.data() ?? {};
      final currentValue = data[type] ?? 0;
      final newValue = currentValue + value;
      
      
      await docRef.update({
        type: newValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      
      await docRef.set({
        'userId': uid,
        'date': today.toIso8601String(),
        type: value,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  
  Future<void> signOut() async {
    await _auth.signOut();
  }

  
  Future<void> checkAndSetupTodayData() async {
    final String uid = currentUserId ?? '';
    if (uid.isEmpty) return;
    
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
    
    
    final docSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('health_data')
        .doc(dateStr)
        .get();
    
    
    if (!docSnapshot.exists) {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('health_data')
          .doc(dateStr)
          .set({
            'userId': uid,
            'date': today.toIso8601String(),
            'steps': 0,
            'calories': 0,
            'water': 0,
            'sleep': 0,
          });
    }
  }
}

