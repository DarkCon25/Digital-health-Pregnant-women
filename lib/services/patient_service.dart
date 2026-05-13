import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import '../models/patient/analysis_model.dart';
import '../models/patient/appointment_model.dart';
import '../models/patient/emergency_alert_model.dart';
import '../models/patient/fetal_image_model.dart';
import '../models/patient_model.dart';

/// All Firestore operations for the patient portal.
class PatientService {
  final _db = FirebaseFirestore.instance;

  // ── Patient profile ────────────────────────────────────────────────────
  Stream<PatientModel?> watchPatient(String uid) => _db
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .snapshots()
      .map((s) => s.exists
          ? PatientModel.fromMap(s.data() as Map<String, dynamic>)
          : null);

  Future<void> updatePatientProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection(AppConstants.usersCollection).doc(uid).update(data);
  }

  // ── Medical file ───────────────────────────────────────────────────────
  Stream<Map<String, dynamic>?> watchMedicalFile(String patientId) => _db
      .collection(AppConstants.medicalFilesCollection)
      .doc(patientId)
      .snapshots()
      .map((s) => s.exists && s.data() != null
          ? _normalizeMedicalFile(s.data()!)
          : null);

  // ── Lab tests / Analyses ───────────────────────────────────────────────
  Stream<List<AnalysisModel>> watchAnalyses(String patientId) => _db
      .collection(AppConstants.labTestsCollection)
      .where('patientId', isEqualTo: patientId)
      .snapshots()
      .map((s) => s.docs.map(AnalysisModel.fromFirestore).toList()
        ..sort((a, b) => b.date.compareTo(a.date)));

  // ── Fetal / Ultrasound images ──────────────────────────────────────────
  Stream<List<FetalImageModel>> watchFetalImages(String patientId) => _db
      .collection(AppConstants.ultrasoundImagesCollection)
      .where('patientId', isEqualTo: patientId)
      .snapshots()
      .map((s) => s.docs.map(FetalImageModel.fromFirestore).toList()
        ..sort((a, b) => b.date.compareTo(a.date)));

  // ── Appointments ───────────────────────────────────────────────────────
  Stream<List<AppointmentModel>> watchAppointments(String patientId) => _db
      .collection(AppConstants.appointmentsCollection)
      .where('patientId', isEqualTo: patientId)
      .snapshots()
      .map((s) => s.docs.map(AppointmentModel.fromFirestore).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime)));

  Future<void> requestAppointment(AppointmentModel appt) async {
    final payload = Map<String, dynamic>.from(appt.toMap());

    if ((payload['patientName'] as String?)?.trim().isEmpty ?? true) {
      final pDoc = await _db
          .collection(AppConstants.usersCollection)
          .doc(appt.patientId)
          .get();
      final p = pDoc.data();
      if (p != null) {
        final fullName =
            '${p['firstName'] ?? ''} ${p['lastName'] ?? ''}'.trim();
        payload['patientName'] = fullName;
      }
    }

    payload['startAt'] ??= payload['dateTime'];
    payload['dateTime'] ??= payload['startAt'];
    payload['requestedBy'] = AppConstants.rolePatient;
    payload['createdAt'] = FieldValue.serverTimestamp();

    await _db.collection(AppConstants.appointmentsCollection).add(payload);
  }

  // ── Emergency alerts ───────────────────────────────────────────────────
  Future<void> sendEmergencyAlert(EmergencyAlertModel alert) async {
    final payload = Map<String, dynamic>.from(alert.toMap());
    payload['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection(AppConstants.emergencyAlertsCollection).add(payload);
  }

  // ── Notifications ──────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> watchNotifications(
      String patientId) =>
      _db
          .collection(AppConstants.notificationsCollection)
          .where('patientId', isEqualTo: patientId)
          .snapshots()
          .map((s) {
        final list = s.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList();
        list.sort((a, b) {
          final ta = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
          final tb = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
          return tb.compareTo(ta);
        });
        return list;
      });

  // ── Doctors list (for appointment request) ─────────────────────────────
  Future<List<Map<String, dynamic>>> getDoctors() async {
    final snap = await _db
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: 'doctor')
        .get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Map<String, dynamic> _normalizeMedicalFile(Map<String, dynamic> raw) {
    final m = Map<String, dynamic>.from(raw);
    final systolic = _toInt(m['bloodPressureSystolic']);
    final diastolic = _toInt(m['bloodPressureDiastolic']);

    if (m['bloodPressure'] == null &&
        (systolic != null || diastolic != null)) {
      m['bloodPressure'] = '${systolic ?? '—'}/${diastolic ?? '—'}';
    }

    m['bloodSugar'] ??= m['bloodGlucose'] ?? m['glucose'] ?? m['sugarLevel'];
    m['glucose'] ??= m['bloodGlucose'] ?? m['bloodSugar'] ?? m['sugarLevel'];
    m['temperature'] ??= m['temperatureCelsius'];
    m['heartRate'] ??= m['fetalHeartRateBpm'] ?? m['heartRateBpm'] ?? m['heartbeat'];
    m['fetalHeartRate'] ??= m['fetalHeartRateBpm'] ?? m['heartRate'];

    return m;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
