import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/doctor/icu_case_model.dart';
import '../models/doctor/medical_file_model.dart';
import '../models/nurse/emergency_request_model.dart';
import '../models/nurse/medication_schedule_model.dart';
import '../models/nurse/nurse_patient_model.dart';
import '../models/nurse/vital_signs_model.dart';
import '../models/room_model.dart';

/// Firestore access for the Nurse role.
class NurseService {
  NurseService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String? get currentUid => _auth.currentUser?.uid;

  Stream<List<NursePatientModel>> watchPatients() {
    return _db
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: AppConstants.rolePatient)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => NursePatientModel.fromMap(d.data()))
          .toList();
      list.sort((a, b) => b.patient.createdAt.compareTo(a.patient.createdAt));
      return list;
    });
  }

  Future<NursePatientModel?> getPatient(String patientId) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(patientId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return NursePatientModel.fromMap(doc.data()!);
  }

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

  Future<void> saveVitalSigns(VitalSignsModel model) async {
    await ensureMedicalFile(model.patientId);
    final hasBloodPressure =
        model.systolic != null || model.diastolic != null;
    final bloodPressureText = hasBloodPressure
        ? '${model.systolic ?? '—'}/${model.diastolic ?? '—'}'
        : null;

    await _db
        .collection(AppConstants.medicalFilesCollection)
        .doc(model.patientId)
        .set({
      ...model.toFirestoreMerge(),
      // Compatibility aliases used in other role dashboards.
      'bloodPressure': bloodPressureText,
      'bloodSugar': model.bloodGlucose,
      'glucose': model.bloodGlucose,
      'heartRate': model.heartRateBpm,
      'temperature': model.temperatureCelsius,
    }, SetOptions(merge: true));

    final hasAnyVitals = model.systolic != null ||
        model.diastolic != null ||
        model.heartRateBpm != null ||
        model.temperatureCelsius != null ||
        model.bloodGlucose != null ||
        model.respiratoryRate != null ||
        model.oxygenSaturationPercent != null;

    if (hasAnyVitals) {
      await _db.collection('pregnancy_monitoring').add({
        'patientId': model.patientId,
        'bloodPressure': bloodPressureText,
        'heartbeat': model.heartRateBpm,
        'temperature': model.temperatureCelsius,
        'sugarLevel': model.bloodGlucose,
        'bloodGlucose': model.bloodGlucose,
        'heartRateBpm': model.heartRateBpm,
        'respiratoryRate': model.respiratoryRate,
        'oxygenSaturationPercent': model.oxygenSaturationPercent,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
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

  Stream<List<MedicationScheduleModel>> watchMedications() {
    return _db
        .collection(AppConstants.medicationSchedulesCollection)
        .limit(200)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => MedicationScheduleModel.fromDoc(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
      return list;
    });
  }

  Future<void> markMedicationAdministered({
    required String scheduleId,
    required String nurseId,
    required String nurseName,
  }) async {
    await _db
        .collection(AppConstants.medicationSchedulesCollection)
        .doc(scheduleId)
        .update({
      'status': 'administered',
      'administeredAt': FieldValue.serverTimestamp(),
      'nurseId': nurseId,
      'nurseName': nurseName,
    });
  }

  Future<void> addMedicationSchedule(MedicationScheduleModel model) async {
    await _db
        .collection(AppConstants.medicationSchedulesCollection)
        .add(model.toMap());
  }

  Stream<List<EmergencyRequestModel>> watchEmergencyRequests() {
    return _db
        .collection(AppConstants.emergencyAlertsCollection)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => EmergencyRequestModel.fromDoc(d.id, d.data()))
          .toList();
      list.sort((a, b) {
        final ta = a.alertTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final tb = b.alertTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        return tb.compareTo(ta);
      });
      return list;
    });
  }

  Future<void> resolveEmergency(String alertId) async {
    try {
      await _db
          .collection(AppConstants.emergencyAlertsCollection)
          .doc(alertId)
          .update({
        'status': 'resolved',
        'resolvedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('NurseService.resolveEmergency: $e');
    }
  }

  Stream<List<RoomModel>> watchRooms() {
    return _db.collection(AppConstants.roomsCollection).snapshots().map((s) {
      final list =
          s.docs.map((d) => RoomModel.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => a.number.compareTo(b.number));
      return list;
    });
  }

  Stream<List<IcuCaseModel>> watchIcuCases() {
    return _db
        .collection(AppConstants.icuCasesCollection)
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

  Stream<QuerySnapshot> watchUpcomingAppointments({int limit = 40}) {
    return _db
        .collection(AppConstants.appointmentsCollection)
        .orderBy('startAt', descending: false)
        .limit(limit)
        .snapshots();
  }

  Stream<QuerySnapshot> watchNotifications({int limit = 50}) {
    return _db
        .collection(AppConstants.notificationsCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  Stream<QuerySnapshot> doctorsStream() {
    return _db
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: AppConstants.roleDoctor)
        .limit(30)
        .snapshots();
  }

  Stream<QuerySnapshot> contactsStream() {
    return _db
        .collection(AppConstants.usersCollection)
        .where('role', whereIn: [
      AppConstants.roleDoctor,
      AppConstants.roleNurse,
      AppConstants.roleAdmin,
    ]).snapshots();
  }

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

  Future<Map<String, int>> getDashboardCounts() async {
    final patients = await _db
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: AppConstants.rolePatient)
        .get();
    var critical = 0;
    for (final d in patients.docs) {
      final s = (d.data()['status'] as String?)?.toLowerCase() ?? '';
      if (s == 'critical') critical++;
    }
    QuerySnapshot icu;
    try {
      icu = await _db
          .collection(AppConstants.icuCasesCollection)
          .where('status', whereIn: ['active', 'critical', 'admitted']).get();
    } catch (_) {
      icu = await _db.collection(AppConstants.icuCasesCollection).limit(50).get();
    }
    QuerySnapshot birthsSnap;
    try {
      birthsSnap = await _db.collection('babies').limit(80).get();
    } catch (_) {
      birthsSnap = await _db.collection(AppConstants.usersCollection).limit(0).get();
    }
    final today = DateTime.now();
    var birthsToday = 0;
    for (final d in birthsSnap.docs) {
      final raw = d.data();
      if (raw is! Map<String, dynamic>) continue;
      final m = raw;
      final created = m['createdAt'];
      if (created is Timestamp) {
        final dt = created.toDate();
        if (dt.year == today.year &&
            dt.month == today.month &&
            dt.day == today.day) {
          birthsToday++;
        }
      }
    }
    return {
      'patients': patients.docs.length,
      'critical': critical,
      'icu': icu.docs.length,
      'birthsToday': birthsToday,
    };
  }
}
