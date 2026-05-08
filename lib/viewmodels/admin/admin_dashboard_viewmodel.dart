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
    'rooms': 0,
    'availableRooms': 0,
  };

  final List<double> monthlyData = [
    45,
    62,
    78,
    55,
    89,
    95,
    110,
    87,
    102,
    115,
    98,
    125,
  ];

  final List<String> monthLabels = AppStrings.monthLabels;

  AdminDashboardViewModel() {
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading = true;
    notifyListeners();
    try {
      stats = await _service.getStats();
    } catch (_) {}
    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => loadStats();

  AdminService get service => _service;
}
