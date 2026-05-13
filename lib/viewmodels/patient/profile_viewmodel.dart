import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/patient_model.dart';
import '../../services/patient_service.dart';

class PatientProfileViewModel extends ChangeNotifier {
  PatientProfileViewModel(this._svc);

  final PatientService _svc;

  PatientModel? patient;
  bool loading = true;
  bool saving = false;
  bool saved = false;
  String? error;

  StreamSubscription<PatientModel?>? _sub;

  void start(String uid) {
    _sub?.cancel();
    loading = true;
    error = null;
    _sub = _svc.watchPatient(uid).listen(
      (p) {
        patient = p;
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

  Future<void> save(String uid, Map<String, dynamic> data) async {
    saving = true;
    error = null;
    notifyListeners();
    try {
      await _svc.updatePatientProfile(uid, data);
      saved = true;
      notifyListeners();
      await Future<void>.delayed(const Duration(seconds: 2));
      saved = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
