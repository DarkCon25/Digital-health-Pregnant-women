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
  String? successMessage;

  // ── Edit mode tracking
  bool isEditMode = false;
  bool isUpdatingStatus = false;
  bool isUpdatingNotes = false;

  // ── Permissions
  bool canEditPatientInfo = true;
  bool canUpdateVitals = true;
  bool canAddConsultation = true;
  bool canEditConsultation = true;
  bool canDeleteConsultation = true;
  bool canPrintPrescription = true;

  StreamSubscription<MedicalFileModel>? _medSub;
  StreamSubscription<List<ConsultationModel>>? _consSub;

  Future<void> init() async {
    loading = true;
    error = null;
    successMessage = null;
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
    if (!canUpdateVitals) {
      error = 'You do not have permission to update vitals';
      notifyListeners();
      return false;
    }

    saving = true;
    error = null;
    successMessage = null;
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

      successMessage = 'Vitals updated successfully';
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
    if (!canAddConsultation) {
      error = 'You do not have permission to add consultations';
      notifyListeners();
      return false;
    }

    if (notes.trim().isEmpty) {
      error = 'Consultation note cannot be empty';
      notifyListeners();
      return false;
    }
    saving = true;
    error = null;
    successMessage = null;
    notifyListeners();
    try {
      await _service.addConsultation(
        patientId: patientId,
        doctorId: doctorId,
        notes: notes,
        diagnosis: diagnosis,
        visitDate: visitDate,
      );

      successMessage = 'Consultation registered successfully';
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

  // ── Toggle edit mode
  void toggleEditMode() {
    isEditMode = !isEditMode;
    if (!isEditMode) {
      error = null;
    }
    notifyListeners();
  }

  void cancelEdit() {
    isEditMode = false;
    error = null;
    successMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    error = null;
    successMessage = null;
    notifyListeners();
  }

  // ── Advanced update operations
  Future<bool> updatePatientStatus(String newStatus) async {
    if (!canEditPatientInfo) {
      error = 'No permission to update patient status';
      notifyListeners();
      return false;
    }

    isUpdatingStatus = true;
    error = null;
    notifyListeners();

    try {
      await _service.updatePatientStatus(
        patientId: patientId,
        status: newStatus,
      );

      isUpdatingStatus = false;
      successMessage = 'Patient status updated';
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isUpdatingStatus = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePatientNotes(String notes) async {
    if (!canEditPatientInfo) {
      error = 'No permission to update notes';
      notifyListeners();
      return false;
    }

    isUpdatingNotes = true;
    error = null;
    notifyListeners();

    try {
      await _service.updatePatientNotes(
        patientId: patientId,
        notes: notes,
      );

      isUpdatingNotes = false;
      successMessage = 'Notes updated successfully';
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isUpdatingNotes = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteConsultation(String consultationId) async {
    if (!canDeleteConsultation) {
      error = 'No permission to delete consultations';
      notifyListeners();
      return false;
    }

    saving = true;
    error = null;
    notifyListeners();

    try {
      await _service.deleteConsultation(
        patientId: patientId,
        consultationId: consultationId,
        doctorId: doctorId,
      );

      saving = false;
      successMessage = 'Consultation deleted';
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      saving = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _medSub?.cancel();
    _consSub?.cancel();
    super.dispose();
  }
}
