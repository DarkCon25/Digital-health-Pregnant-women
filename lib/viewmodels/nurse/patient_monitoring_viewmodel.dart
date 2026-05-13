import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/doctor/medical_file_model.dart';
import '../../models/nurse/nurse_patient_model.dart';
import '../../models/nurse/vital_signs_model.dart';
import '../../services/nurse_service.dart';

class PatientMonitoringViewModel extends ChangeNotifier {
  PatientMonitoringViewModel(this._service, this.patientId);

  final NurseService _service;
  final String patientId;

  NursePatientModel? patient;
  MedicalFileModel? medical;
  bool loading = true;
  bool saving = false;
  String? error;

  int? systolic;
  int? diastolic;
  int? heartRate;
  int? respiratoryRate;
  int? oxygenSaturation;
  double? temperature;
  double? glucose;
  String notes = '';

  Future<void> init() async {
    loading = true;
    notifyListeners();
    try {
      patient = await _service.getPatient(patientId);
      medical = await _service.watchMedicalFile(patientId).first;
      final m = medical!;
      systolic = m.bloodPressureSystolic;
      diastolic = m.bloodPressureDiastolic;
      heartRate = m.heartRateBpm;
      temperature = m.temperatureCelsius;
      glucose = m.bloodGlucose;
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  void setSystolic(int? v) {
    systolic = v;
    notifyListeners();
  }

  void setDiastolic(int? v) {
    diastolic = v;
    notifyListeners();
  }

  void setHeartRate(int? v) {
    heartRate = v;
    notifyListeners();
  }

  void setRespiratory(int? v) {
    respiratoryRate = v;
    notifyListeners();
  }

  void setOxygen(int? v) {
    oxygenSaturation = v;
    notifyListeners();
  }

  void setTemp(double? v) {
    temperature = v;
    notifyListeners();
  }

  void setGlucose(double? v) {
    glucose = v;
    notifyListeners();
  }

  void setNotes(String v) {
    notes = v;
    notifyListeners();
  }

  Future<void> save() async {
    saving = true;
    notifyListeners();
    try {
      await _service.saveVitalSigns(
        VitalSignsModel(
          patientId: patientId,
          systolic: systolic,
          diastolic: diastolic,
          heartRateBpm: heartRate,
          respiratoryRate: respiratoryRate,
          oxygenSaturationPercent: oxygenSaturation,
          temperatureCelsius: temperature,
          bloodGlucose: glucose,
        ),
      );
    } catch (e) {
      error = e.toString();
    }
    saving = false;
    notifyListeners();
  }
}
