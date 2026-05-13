import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/nurse/medication_schedule_model.dart';
import '../../services/nurse_service.dart';

class MedicationsViewModel extends ChangeNotifier {
  MedicationsViewModel(this._service);

  final NurseService _service;

  int tabIndex = 0;
  List<MedicationScheduleModel> _all = [];

  StreamSubscription<List<MedicationScheduleModel>>? _sub;

  List<MedicationScheduleModel> get filtered {
    final now = DateTime.now();
    bool sameDay(DateTime a) =>
        a.year == now.year && a.month == now.month && a.day == now.day;
    switch (tabIndex) {
      case 0:
        return _all.where((m) => !m.isAdministered && sameDay(m.scheduledAt)).toList();
      case 2:
        return _all.where((m) => m.isAdministered).toList();
      default:
        return _all.where((m) => !m.isAdministered).toList();
    }
  }

  void start() {
    _sub?.cancel();
    _sub = _service.watchMedications().listen((list) {
      _all = list;
      notifyListeners();
    });
  }

  void setTab(int i) {
    tabIndex = i.clamp(0, 2);
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
