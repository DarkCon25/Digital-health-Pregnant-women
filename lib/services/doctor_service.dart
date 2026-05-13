import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/doctor/consultation_model.dart';
import '../models/doctor/emergency_alert_model.dart';
import '../models/doctor/icu_case_model.dart';
import '../models/doctor/lab_test_model.dart';
import '../models/doctor/medical_file_model.dart';
import '../models/doctor/ultrasound_image_model.dart';
import '../models/patient_model.dart';
import '../models/room_model.dart';

/// Firestore access for the Doctor role (patients, vitals, alerts, appointments).
class DoctorService {
  DoctorService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String? get currentUid => _auth.currentUser?.uid;

  // ── Patients (users collection, role == patient) ─────────────────

  Stream<List<PatientModel>> watchPatientsForDoctor(String doctorId) {
    return _db
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: AppConstants.rolePatient)
        .where('assignedDoctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => PatientModel.fromMap(d.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<PatientModel?> getPatient(String patientId) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(patientId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return PatientModel.fromMap(doc.data()!);
  }

  /// Assign an existing patient account to this doctor (by email).
  Future<String?> assignPatientToMe({
    required String doctorId,
    required String doctorDisplayName,
    required String patientEmail,
  }) async {
    final email = patientEmail.trim().toLowerCase();
    if (email.isEmpty) return 'empty_email';

    final q = await _db
        .collection(AppConstants.usersCollection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (q.docs.isEmpty) return 'not_found';

    final doc = q.docs.first;
    final data = doc.data();
    if ((data['role'] as String?) != AppConstants.rolePatient) {
      return 'not_patient';
    }

    final previousDoctorId = data['assignedDoctorId'] as String?;
    if (previousDoctorId == doctorId) return 'already_assigned';

    await _db.collection(AppConstants.usersCollection).doc(doc.id).update({
      'assignedDoctorId': doctorId,
      'assignedDoctorName': doctorDisplayName,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _db.collection(AppConstants.usersCollection).doc(doctorId).update({
      'patients': FieldValue.increment(1),
    });

    if (previousDoctorId != null && previousDoctorId.isNotEmpty) {
      await _db
          .collection(AppConstants.usersCollection)
          .doc(previousDoctorId)
          .update({
        'patients': FieldValue.increment(-1),
      });
    }

    return null;
  }

  // ── Medical file (vitals) ───────────────────────────────────────

  Stream<MedicalFileModel> watchMedicalFile(String patientId) {
    return _db
        .collection(AppConstants.medicalFilesCollection)
        .doc(patientId)
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) {
        return MedicalFileModel.empty(patientId);
      }
      return MedicalFileModel.fromDoc(patientId, snap.data()!);
    });
  }

  Future<void> ensureMedicalFile(String patientId) async {
    final ref =
        _db.collection(AppConstants.medicalFilesCollection).doc(patientId);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'patientId': patientId,
        'visitCount': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateVitals({
    required String patientId,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? heartRateBpm,
    int? fetalHeartRateBpm,
    double? bloodGlucose,
    double? temperatureCelsius,
  }) async {
    await ensureMedicalFile(patientId);
    final hasBloodPressure =
        bloodPressureSystolic != null || bloodPressureDiastolic != null;
    final bloodPressureText = hasBloodPressure
        ? '${bloodPressureSystolic ?? '—'}/${bloodPressureDiastolic ?? '—'}'
        : null;

    await _db
        .collection(AppConstants.medicalFilesCollection)
        .doc(patientId)
        .set({
      'patientId': patientId,
      'bloodPressureSystolic': bloodPressureSystolic,
      'bloodPressureDiastolic': bloodPressureDiastolic,
      'heartRateBpm': heartRateBpm,
      'fetalHeartRateBpm': fetalHeartRateBpm,
      'bloodGlucose': bloodGlucose,
      'temperatureCelsius': temperatureCelsius,
      // Compatibility aliases used by patient/admin UI modules.
      'bloodPressure': bloodPressureText,
      'bloodSugar': bloodGlucose,
      'glucose': bloodGlucose,
      'heartRate': fetalHeartRateBpm ?? heartRateBpm,
      'temperature': temperatureCelsius,
      'lastVisitAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final hasAnyVitals = bloodPressureSystolic != null ||
        bloodPressureDiastolic != null ||
        heartRateBpm != null ||
        fetalHeartRateBpm != null ||
        bloodGlucose != null ||
        temperatureCelsius != null;

    if (hasAnyVitals) {
      await _db.collection('pregnancy_monitoring').add({
        'patientId': patientId,
        'sugarLevel': bloodGlucose,
        'bloodPressure': bloodPressureText,
        'heartbeat': heartRateBpm,
        'fetalHeartbeat': fetalHeartRateBpm,
        'temperature': temperatureCelsius,
        'bloodGlucose': bloodGlucose,
        'heartRateBpm': heartRateBpm,
        'fetalHeartRateBpm': fetalHeartRateBpm,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> incrementVisitCount(String patientId) async {
    await ensureMedicalFile(patientId);
    await _db
        .collection(AppConstants.medicalFilesCollection)
        .doc(patientId)
        .update({
      'visitCount': FieldValue.increment(1),
      'lastVisitAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Consultations ────────────────────────────────────────────────

  Stream<List<ConsultationModel>> watchConsultations(String patientId) {
    return _db
        .collection(AppConstants.medicalFilesCollection)
        .doc(patientId)
        .collection(AppConstants.consultationsSubcollection)
        .orderBy('visitDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ConsultationModel.fromDoc(d.id, d.data()))
            .toList());
  }

  Future<void> addConsultation({
    required String patientId,
    required String doctorId,
    required String notes,
    String? diagnosis,
    required DateTime visitDate,
  }) async {
    await ensureMedicalFile(patientId);
    await _db
        .collection(AppConstants.medicalFilesCollection)
        .doc(patientId)
        .collection(AppConstants.consultationsSubcollection)
        .add({
      'patientId': patientId,
      'doctorId': doctorId,
      'notes': notes,
      'diagnosis': diagnosis,
      'visitDate': Timestamp.fromDate(visitDate),
      'createdAt': FieldValue.serverTimestamp(),
    });
    await incrementVisitCount(patientId);
  }

  // ── Emergency alerts (filter to doctor’s patients client-side) ───

  Stream<List<EmergencyAlertModel>> watchEmergencyAlerts() {
    return _db
        .collection(AppConstants.emergencyAlertsCollection)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => EmergencyAlertModel.fromDoc(d.id, d.data()))
          .toList();
      list.sort((a, b) {
        final ta = a.alertTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final tb = b.alertTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        return tb.compareTo(ta);
      });
      return list;
    });
  }

  // ── Appointments ────────────────────────────────────────────────

  Stream<List<DoctorAppointmentModel>> watchAppointments(String doctorId) {
    return _db
        .collection(AppConstants.appointmentsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => DoctorAppointmentModel.fromDoc(d.id, d.data()))
          .toList();
      list.sort((a, b) => a.startAt.compareTo(b.startAt));
      return list;
    });
  }

  Future<void> addAppointment({
    required String doctorId,
    required String patientId,
    required String patientName,
    required DateTime startAt,
    String? notes,
  }) async {
    String doctorName = '';
    try {
      final doctorDoc =
          await _db.collection(AppConstants.usersCollection).doc(doctorId).get();
      final doctorData = doctorDoc.data();
      if (doctorData != null) {
        doctorName =
            '${doctorData['firstName'] ?? ''} ${doctorData['lastName'] ?? ''}'
                .trim();
      }
    } catch (_) {}

    await _db.collection(AppConstants.appointmentsCollection).add({
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientId': patientId,
      'patientName': patientName,
      'startAt': Timestamp.fromDate(startAt),
      'dateTime': Timestamp.fromDate(startAt),
      'type': 'Consultation',
      'status': 'scheduled',
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Messages (same schema as AdminService.sendMessage) ───────────

  Stream<QuerySnapshot> messagesForChat(String contactId) {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null) {
      return const Stream<QuerySnapshot>.empty();
    }
    final ids = [myUid, contactId]..sort();
    final chatId = '${ids[0]}_${ids[1]}';
    return _db
        .collection(AppConstants.messagesCollection)
        .where('chatId', isEqualTo: chatId)
        .snapshots();
  }

  Future<void> sendMessage(String contactId, String text) async {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null) return;
    final ids = [myUid, contactId]..sort();
    final chatId = '${ids[0]}_${ids[1]}';

    await _db.collection(AppConstants.messagesCollection).add({
      'senderId': myUid,
      'receiverId': contactId,
      'chatId': chatId,
      'participants': [myUid, contactId],
      'text': text.trim(),
      'seen': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<int> unreadCountStream(String contactId) {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null) return Stream<int>.value(0);
    return _db
        .collection(AppConstants.messagesCollection)
        .where('senderId', isEqualTo: contactId)
        .where('receiverId', isEqualTo: myUid)
        .where('seen', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  Future<void> markMessagesAsRead(String contactId) async {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null) return;
    final q = await _db
        .collection(AppConstants.messagesCollection)
        .where('senderId', isEqualTo: contactId)
        .where('receiverId', isEqualTo: myUid)
        .where('seen', isEqualTo: false)
        .get();
    if (q.docs.isEmpty) return;
    final batch = _db.batch();
    for (final d in q.docs) {
      batch.update(d.reference, {'seen': true});
    }
    await batch.commit();
  }

  Stream<int> totalUnreadMessagesStream() {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null) return Stream<int>.value(0);
    return _db
        .collection(AppConstants.messagesCollection)
        .where('receiverId', isEqualTo: myUid)
        .where('seen', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  Stream<QuerySnapshot> staffContactsStream() {
    return _db
        .collection(AppConstants.usersCollection)
        .where('role', whereIn: [
      AppConstants.roleNurse,
      AppConstants.roleDoctor,
      AppConstants.roleAdmin,
    ]).snapshots();
  }

  Future<void> resolveEmergencyAlert(String alertId) async {
    try {
      await _db
          .collection(AppConstants.emergencyAlertsCollection)
          .doc(alertId)
          .update({
        'status': 'resolved',
        'resolvedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('DoctorService.resolveEmergencyAlert: $e');
    }
  }

  /// Historical rows for charts (weight, sugar, etc.) — same collection as admin profile.
  Future<List<Map<String, dynamic>>> getPregnancyMonitoringHistory(
    String patientId, {
    int limit = 20,
  }) async {
    final q = await _db
        .collection('pregnancy_monitoring')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: false)
        .limit(limit)
        .get();
    return q.docs.map((d) => d.data()).toList();
  }

  Stream<List<Map<String, dynamic>>> watchPregnancyMonitoring(
    String patientId,
  ) {
    return _db
        .collection('pregnancy_monitoring')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => d.data()).toList();
      list.sort((a, b) {
        final ta = a['createdAt'];
        final tb = b['createdAt'];
        if (ta is! Timestamp) return -1;
        if (tb is! Timestamp) return 1;
        return ta.compareTo(tb);
      });
      return list;
    });
  }

  // ── Rooms (ولادة / عامة) ─────────────────────────────────────────

  Stream<List<RoomModel>> watchRooms() {
    return _db.collection(AppConstants.roomsCollection).snapshots().map((s) {
      final list =
          s.docs.map((d) => RoomModel.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => a.number.compareTo(b.number));
      return list;
    });
  }

  // ── Lab tests ─────────────────────────────────────────────────────

  Stream<List<LabTestModel>> watchLabTests(String doctorId) {
    return _db
        .collection(AppConstants.labTestsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => LabTestModel.fromDoc(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.testDate.compareTo(a.testDate));
      return list;
    });
  }

  Stream<List<LabTestModel>> watchLabTestsForPatient(
    String doctorId,
    String patientId,
  ) {
    return watchLabTests(doctorId).map(
      (list) => list.where((t) => t.patientId == patientId).toList(),
    );
  }


  Future<void> addLabTest(LabTestModel model) async {
    await _db.collection(AppConstants.labTestsCollection).add(model.toMap());
  }

  // ── Ultrasound gallery ────────────────────────────────────────────

  Stream<List<UltrasoundImageModel>> watchUltrasoundsForDoctor(
    String doctorId,
  ) {
    return _db
        .collection(AppConstants.ultrasoundImagesCollection)
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => UltrasoundImageModel.fromDoc(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<UltrasoundImageModel>> watchUltrasoundsForPatient(
    String patientId,
  ) {
    return _db
        .collection(AppConstants.ultrasoundImagesCollection)
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => UltrasoundImageModel.fromDoc(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> addUltrasoundImage({
    required String doctorId,
    required String patientId,
    required String imageUrl,
    String? sessionLabel,
  }) async {
    await _db.collection(AppConstants.ultrasoundImagesCollection).add({
      'doctorId': doctorId,
      'patientId': patientId,
      'imageUrl': imageUrl,
      'sessionLabel': sessionLabel,
      'notes': sessionLabel,
      'date': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── ICU cases (حالات العناية المركزة) ─────────────────────────────

  Stream<List<IcuCaseModel>> watchIcuCases(String doctorId) {
    return _db
        .collection(AppConstants.icuCasesCollection)
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => IcuCaseModel.fromDoc(d.id, d.data()))
          .toList();
      list.sort((a, b) {
        final ta = a.admittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final tb = b.admittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return tb.compareTo(ta);
      });
      return list;
    });
  }

  Future<void> addIcuCase(IcuCaseModel model) async {
    await _db.collection(AppConstants.icuCasesCollection).add(model.toMap());
  }

  Future<void> updateIcuCaseStatus(String id, String status) async {
    await _db.collection(AppConstants.icuCasesCollection).doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Notifications (نفس مجموعة الإدارة) ─────────────────────────────

  Stream<QuerySnapshot> watchNotifications({int limit = 50}) {
    return _db
        .collection(AppConstants.notificationsCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  // ── Report aggregates ─────────────────────────────────────────────

  Future<Map<String, int>> getReportCounts(String doctorId) async {
    final patientIds = await _db
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: AppConstants.rolePatient)
        .where('assignedDoctorId', isEqualTo: doctorId)
        .get()
        .then((s) => s.docs.map((d) => d.id).toSet());

    final lab = await _db
        .collection(AppConstants.labTestsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .count()
        .get();
    final ultra = await _db
        .collection(AppConstants.ultrasoundImagesCollection)
        .where('doctorId', isEqualTo: doctorId)
        .count()
        .get();
    final icu = await _db
        .collection(AppConstants.icuCasesCollection)
        .where('doctorId', isEqualTo: doctorId)
        .count()
        .get();

    var consultCount = 0;
    for (final pid in patientIds) {
      final c = await _db
          .collection(AppConstants.medicalFilesCollection)
          .doc(pid)
          .collection(AppConstants.consultationsSubcollection)
          .count()
          .get();
      consultCount += c.count ?? 0;
    }

    return {
      'patients': patientIds.length,
      'labTests': lab.count ?? 0,
      'ultrasounds': ultra.count ?? 0,
      'icuCases': icu.count ?? 0,
      'consultations': consultCount,
    };
  }
}
