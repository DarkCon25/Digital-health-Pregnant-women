import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/app_strings.dart';
import '../../services/admin_service.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  final AdminService _service = AdminService();

  bool isLoading = false;
  Map<String, int> stats = {
    'patients': 0,
    'doctors': 0,
    'nurses': 0,
    'babies': 0,
    'rooms': 0,
    'availableRooms': 0,
  };

  // Dynamic monthly data based on real data
  List<double> monthlyPatients = List.filled(12, 0);
  List<double> monthlyBabies = List.filled(12, 0);
  List<double> monthlyDoctors = List.filled(12, 0);
  List<double> monthlyNurses = List.filled(12, 0);

  final List<String> monthLabels = AppStrings.monthLabels;

  AdminDashboardViewModel() {
    loadStats();
    _initializeDynamicData();
  }

  /// Initialize dynamic data from Firestore
  void _initializeDynamicData() {
    // Listen to patients, babies, and nurses changes
    _service.getPatientsStream().listen((_) => loadStats());
    _listenToActivities();
  }

  /// Listen to activity streams and update monthly data
  void _listenToActivities() {
    FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .snapshots()
        .listen((snapshot) {
      _updateMonthlyDataFromUsers(snapshot, 'patient');
    });

    FirebaseFirestore.instance
        .collection('babies')
        .snapshots()
        .listen((snapshot) {
      _updateMonthlyDataFromBabies(snapshot);
    });

    FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'nurse')
        .snapshots()
        .listen((snapshot) {
      _updateMonthlyDataFromUsers(snapshot, 'nurse');
    });

    FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .snapshots()
        .listen((snapshot) {
      _updateMonthlyDataFromUsers(snapshot, 'doctor');
    });
  }

  /// Update monthly patient data from Firestore
  void _updateMonthlyDataFromUsers(
    QuerySnapshot snapshot,
    String type,
  ) {
    final newMonthlyData = List<double>.filled(12, 0);

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = data['createdAt'] as Timestamp?;

      if (createdAt != null) {
        final month = createdAt.toDate().month - 1;
        if (month >= 0 && month < 12) {
          newMonthlyData[month]++;
        }
      }
    }

    if (type == 'patient') {
      monthlyPatients = newMonthlyData;
    } else if (type == 'nurse') {
      monthlyNurses = newMonthlyData;
    } else if (type == 'doctor') {
      monthlyDoctors = newMonthlyData;
    }

    notifyListeners();
  }

  /// Update monthly babies data from Firestore
  void _updateMonthlyDataFromBabies(QuerySnapshot snapshot) {
    final newMonthlyData = List<double>.filled(12, 0);

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final birthDate = data['birthDate'] as Timestamp?;

      if (birthDate != null) {
        final month = birthDate.toDate().month - 1;
        if (month >= 0 && month < 12) {
          newMonthlyData[month]++;
        }
      }
    }

    monthlyBabies = newMonthlyData;
    notifyListeners();
  }

  Future<void> loadStats() async {
    isLoading = true;
    notifyListeners();
    try {
      final baseStats = await _service.getStats();

      // Count babies from Firestore
      final babiesSnapshot =
          await FirebaseFirestore.instance.collection('babies').count().get();
      final babiesCount = babiesSnapshot.count ?? 0;

      stats = {
        ...baseStats,
        'babies': babiesCount,
      };

      // Update monthly data
      _listenToActivities();
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => loadStats();

  AdminService get service => _service;

  /// Get pie chart data for gender distribution
  Map<String, int> getGenderDistribution(List<Map<String, dynamic>> babies) {
    int males = 0, females = 0;
    for (var baby in babies) {
      if (baby['gender'] == 'male') males++;
      if (baby['gender'] == 'female') females++;
    }
    return {'males': males, 'females': females};
  }

  /// Get pie chart data for health status
  Map<String, int> getHealthStatusDistribution(
    List<Map<String, dynamic>> babies,
  ) {
    int healthy = 0, needsCare = 0, critical = 0;
    for (var baby in babies) {
      final status = baby['healthStatus'] ?? 'healthy';
      if (status == 'healthy') healthy++;
      if (status == 'needs_care') needsCare++;
      if (status == 'critical') critical++;
    }
    return {'healthy': healthy, 'needsCare': needsCare, 'critical': critical};
  }
}
