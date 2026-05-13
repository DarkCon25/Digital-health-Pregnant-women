import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/doctor/consultation_model.dart';
import '../../models/doctor/medical_file_model.dart';
import '../../models/patient_model.dart';
import '../../services/doctor_service.dart';

class MedicalFileViewModel extends ChangeNotifier {
  MedicalFileViewModel(
    this._service,
    this.patientId,
    this.doctorId,
  );

  final DoctorService _service;
  final String patientId;
  final String doctorId;

  PatientModel? patient;
  MedicalFileModel? medical;
  List<ConsultationModel> consultations = [];
  List<Map<String, dynamic>> monitoringHistory = [];
  bool loading = true;
  bool saving = false;
  String? error;

  StreamSubscription<MedicalFileModel>? _medSub;
  StreamSubscription<List<ConsultationModel>>? _consSub;

  Future<void> init() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      patient = await _service.getPatient(patientId);
      await _service.ensureMedicalFile(patientId);
      monitoringHistory =
          await _service.getPregnancyMonitoringHistory(patientId, limit: 30);
    } catch (e) {
      error = e.toString();
    }

    _medSub?.cancel();
    _consSub?.cancel();

    _medSub = _service.watchMedicalFile(patientId).listen((m) {
      medical = m;
      notifyListeners();
    });

    _consSub = _service.watchConsultations(patientId).listen((c) {
      consultations = c;
      notifyListeners();
    });

    loading = false;
    notifyListeners();
  }

  Future<bool> saveVitals({
    required int? systolic,
    required int? diastolic,
    required int? heartRate,
    required int? fetalHr,
    required double? glucose,
    required double? temp,
  }) async {
    saving = true;
    notifyListeners();
    try {
      await _service.updateVitals(
        patientId: patientId,
        bloodPressureSystolic: systolic,
        bloodPressureDiastolic: diastolic,
        heartRateBpm: heartRate,
        fetalHeartRateBpm: fetalHr,
        bloodGlucose: glucose,
        temperatureCelsius: temp,
      );
      monitoringHistory =
          await _service.getPregnancyMonitoringHistory(patientId, limit: 30);
      saving = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      saving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addConsultationNote({
    required String notes,
    String? diagnosis,
    required DateTime visitDate,
  }) async {
    if (notes.trim().isEmpty) {
      error = 'Consultation note cannot be empty';
      notifyListeners();
      return false;
    }
    saving = true;
    notifyListeners();
    try {
      await _service.addConsultation(
        patientId: patientId,
        doctorId: doctorId,
        notes: notes,
        diagnosis: diagnosis,
        visitDate: visitDate,
      );
      saving = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      saving = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshHistory() async {
    monitoringHistory =
        await _service.getPregnancyMonitoringHistory(patientId, limit: 30);
    notifyListeners();
  }

  @override
  void dispose() {
    _medSub?.cancel();
    _consSub?.cancel();
    super.dispose();
  }
}
