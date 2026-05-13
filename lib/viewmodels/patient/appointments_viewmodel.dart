import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/patient/appointment_model.dart';
import '../../services/patient_service.dart';

class PatientAppointmentsViewModel extends ChangeNotifier {
  PatientAppointmentsViewModel(this._svc);

  final PatientService _svc;

  List<AppointmentModel> all = [];
  bool loading = true;
  bool requestSent = false;
  String? error;

  StreamSubscription<List<AppointmentModel>>? _sub;

  void start(String patientId) {
    _sub?.cancel();
    loading = true;
    error = null;
    _sub = _svc.watchAppointments(patientId).listen(
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

  List<AppointmentModel> get upcoming => all
      .where((a) =>
          a.dateTime.isAfter(DateTime.now()) && a.status != 'cancelled')
      .toList();

  List<AppointmentModel> get past => all
      .where((a) =>
          a.dateTime.isBefore(DateTime.now()) || a.status == 'completed')
      .toList();

  Future<void> requestAppointment({
    required String patientId,
    String? patientName,
    required String doctorId,
    required String doctorName,
    required String type,
    required DateTime dateTime,
    String? notes,
  }) async {
    try {
      await _svc.requestAppointment(
        AppointmentModel(
          id: '',
          patientId: patientId,
          patientName: patientName,
          doctorId: doctorId,
          doctorName: doctorName,
          type: type,
          dateTime: dateTime,
          status: 'pending',
          notes: notes,
          createdAt: DateTime.now(),
        ),
      );
      requestSent = true;
      notifyListeners();
      await Future<void>.delayed(const Duration(seconds: 3));
      requestSent = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
