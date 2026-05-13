import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/patient/analysis_model.dart';
import '../../services/patient_service.dart';

class AnalysesViewModel extends ChangeNotifier {
  AnalysesViewModel(this._svc);

  final PatientService _svc;

  List<AnalysisModel> all = [];
  String activeTab = 'all'; // all | blood | urine | other
  bool loading = true;
  String? error;

  StreamSubscription<List<AnalysisModel>>? _sub;

  void start(String patientId) {
    _sub?.cancel();
    loading = true;
    error = null;
    _sub = _svc.watchAnalyses(patientId).listen(
      (a) {
        all = a;
        loading = false;
        notifyListeners();
      },
      onError: (e) {
        error = e.toString();
        loading = false;
        notifyListeners();
      },
    );
  }

  List<AnalysisModel> get filtered {
    if (activeTab == 'all') return all;
    return all.where((a) => a.category == activeTab).toList();
  }

  void setTab(String tab) {
    activeTab = tab;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
