import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/doctor/consultation_model.dart';
import '../../models/doctor/emergency_alert_model.dart';
import '../../models/doctor/ultrasound_image_model.dart';
import '../../models/patient_model.dart';
import '../../services/doctor_service.dart';

class DoctorDashboardViewModel extends ChangeNotifier {
  DoctorDashboardViewModel(this._service);

  final DoctorService _service;

  String? _doctorId;
  List<PatientModel> patients = [];
  List<EmergencyAlertModel> _allAlerts = [];
  List<EmergencyAlertModel> openAlertsForMyPatients = [];
  List<DoctorAppointmentModel> appointments = [];
  List<Map<String, dynamic>> chartRows = [];
  List<UltrasoundImageModel> recentUltrasounds = [];
  bool loading = true;
  String? error;

  StreamSubscription<List<PatientModel>>? _patientsSub;
  StreamSubscription<List<EmergencyAlertModel>>? _alertsSub;
  StreamSubscription<List<DoctorAppointmentModel>>? _apptSub;
  StreamSubscription<List<UltrasoundImageModel>>? _ultraSub;
  Timer? _chartDebounce;

  void start(String doctorId) {
    if (_doctorId == doctorId &&
        _patientsSub != null &&
        _alertsSub != null &&
        _ultraSub != null) {
      return;
    }
    _doctorId = doctorId;
    loading = true;
    error = null;
    notifyListeners();

    _patientsSub?.cancel();
    _alertsSub?.cancel();
    _apptSub?.cancel();
    _ultraSub?.cancel();

    _ultraSub = _service.watchUltrasoundsForDoctor(doctorId).listen((list) {
      recentUltrasounds = list.take(12).toList();
      notifyListeners();
    });

    _patientsSub =
        _service.watchPatientsForDoctor(doctorId).listen((list) {
      patients = list;
      loading = false;
      error = null;
      _applyAlertFilter();
      _scheduleChartReload();
      notifyListeners();
    }, onError: (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    });

    _alertsSub = _service.watchEmergencyAlerts().listen((list) {
      _allAlerts = list;
      _applyAlertFilter();
      notifyListeners();
    });

    _apptSub = _service.watchAppointments(doctorId).listen((list) {
      appointments = list;
      notifyListeners();
    });
  }

  void _applyAlertFilter() {
    final ids = patients.map((e) => e.uid).toSet();
    openAlertsForMyPatients = _allAlerts
        .where((al) => ids.contains(al.patientId) && al.isOpen)
        .toList();
  }

  void _scheduleChartReload() {
    _chartDebounce?.cancel();
    _chartDebounce = Timer(const Duration(milliseconds: 400), _reloadChart);
  }

  Future<void> _reloadChart() async {
    if (patients.isEmpty) {
      chartRows = [];
      notifyListeners();
      return;
    }
    final focus = patients.firstWhere(
      (p) => p.status.toLowerCase() == 'critical',
      orElse: () => patients.first,
    );
    try {
      chartRows = await _service.getPregnancyMonitoringHistory(focus.uid);
    } catch (_) {
      chartRows = [];
    }
    notifyListeners();
  }

  int get totalPatients => patients.length;

  int get criticalCount =>
      patients.where((p) => p.status.toLowerCase() == 'critical').length;

  int get newPatientsLast7Days {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return patients.where((p) => p.createdAt.isAfter(cutoff)).length;
  }

  int get upcomingAppointmentsCount => appointments
      .where((a) =>
          a.startAt.isAfter(DateTime.now()) &&
          a.status.toLowerCase() != 'cancelled')
      .length;

  /// مريضات لهن غرفة (مقيمات / تمهيد لغرف الولادة).
  int get patientsInHospitalCount => patients
      .where((p) =>
          p.roomNumber != null && p.roomNumber!.trim().isNotEmpty)
      .length;

  int get newAlertsCount => openAlertsForMyPatients.length;

  PatientModel? get spotlightPatient {
    if (patients.isEmpty) return null;
    return patients.firstWhere(
      (p) => p.status.toLowerCase() == 'critical',
      orElse: () => patients.first,
    );
  }

  @override
  void dispose() {
    _chartDebounce?.cancel();
    _patientsSub?.cancel();
    _alertsSub?.cancel();
    _apptSub?.cancel();
    _ultraSub?.cancel();
    super.dispose();
  }
}
