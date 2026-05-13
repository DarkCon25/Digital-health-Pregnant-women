import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/nurse/emergency_request_model.dart';
import '../../services/nurse_service.dart';

class NurseDashboardViewModel extends ChangeNotifier {
  NurseDashboardViewModel(this._service);

  final NurseService _service;

  Map<String, int>? counts;
  List<EmergencyRequestModel> recentAlerts = [];
  bool loading = true;
  String? error;

  StreamSubscription<List<EmergencyRequestModel>>? _alertSub;

  Future<void> start() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      counts = await _service.getDashboardCounts();
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();

    _alertSub?.cancel();
    _alertSub = _service.watchEmergencyRequests().listen((list) {
      recentAlerts = list.where((a) => a.isOpen).take(8).toList();
      notifyListeners();
    });
  }

  Future<void> refreshCounts() async {
    try {
      counts = await _service.getDashboardCounts();
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _alertSub?.cancel();
    super.dispose();
  }
}
