import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/patient/fetal_image_model.dart';
import '../../models/patient_model.dart';
import '../../services/patient_service.dart';

class PatientDashboardViewModel extends ChangeNotifier {
  PatientDashboardViewModel(this._svc);

  final PatientService _svc;

  PatientModel? patient;
  Map<String, dynamic>? medFile;
  List<FetalImageModel> recentImages = [];
  bool loading = true;
  String? error;

  StreamSubscription<PatientModel?>? _patientSub;
  StreamSubscription<Map<String, dynamic>?>? _fileSub;
  StreamSubscription<List<FetalImageModel>>? _imgSub;

  void start(String uid) {
    loading = true;
    error = null;
    _patientSub?.cancel();
    _fileSub?.cancel();
    _imgSub?.cancel();

    _patientSub = _svc.watchPatient(uid).listen(
      (p) {
        patient = p;
        loading = false;
        notifyListeners();
        if (p != null) _startSubStreams(p.uid);
      },
      onError: (e) {
        error = e.toString();
        loading = false;
        notifyListeners();
      },
    );
  }

  void _startSubStreams(String uid) {
    _fileSub?.cancel();
    _imgSub?.cancel();

    _fileSub = _svc.watchMedicalFile(uid).listen((f) {
      medFile = f;
      notifyListeners();
    });

    _imgSub = _svc.watchFetalImages(uid).listen((imgs) {
      recentImages = imgs.take(4).toList();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _patientSub?.cancel();
    _fileSub?.cancel();
    _imgSub?.cancel();
    super.dispose();
  }
}
