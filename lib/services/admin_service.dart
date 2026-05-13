import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

// ════════════════════════════════════════════════════════════════
// HerCare - Admin Service (Complete & Secure)
// Service Admin (Complet et sécurisé)
// ════════════════════════════════════════════════════════════════

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _lastError;
  String? get lastError => _lastError;

  // Secondary Auth Instance for creating users without logout
  static const String _secondaryAppName = 'hercare-admin-auth';
  FirebaseAuth? _secondaryAuth;

  AdminService();

  Future<FirebaseAuth> _getSecondaryAuth() async {
    try {
      if (_secondaryAuth != null) return _secondaryAuth!;

      FirebaseApp app;
      try {
        app = Firebase.app(_secondaryAppName);
      } catch (_) {
        app = await Firebase.initializeApp(
          name: _secondaryAppName,
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      _secondaryAuth = FirebaseAuth.instanceFor(app: app);
      return _secondaryAuth!;
    } catch (e) {
      debugPrint('❌ Failed to initialize secondary auth: $e');
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // STATISTICS / STATISTIQUES
  // ══════════════════════════════════════════════════════════════

  Future<Map<String, int>> getStats() async {
    try {
      final results = await Future.wait([
        _db
            .collection('users')
            .where('role', isEqualTo: 'patient')
            .count()
            .get(),
        _db
            .collection('users')
            .where('role', isEqualTo: 'doctor')
            .count()
            .get(),
        _db.collection('users').where('role', isEqualTo: 'nurse').count().get(),
        _db.collection('rooms').count().get(),
        _db
            .collection('rooms')
            .where('status', isEqualTo: 'available')
            .count()
            .get(),
      ]);

      return {
        'patients': results[0].count ?? 0,
        'doctors': results[1].count ?? 0,
        'nurses': results[2].count ?? 0,
        'rooms': results[3].count ?? 0,
        'availableRooms': results[4].count ?? 0,
      };
    } catch (e) {
      debugPrint('❌ Error fetching stats: $e');

      return {
        'patients': 0,
        'doctors': 0,
        'nurses': 0,
        'rooms': 0,
        'availableRooms': 0,
      };
    }
  }

  Stream<Map<String, int>> getStatsStream() {
    return Stream.periodic(
      const Duration(seconds: 5),
      (_) => getStats(),
    ).asyncMap((event) => event);
  }

  // ══════════════════════════════════════════════════════════════
  // DOCTORS / MÉDECINS
  // ══════════════════════════════════════════════════════════════

  Stream<QuerySnapshot> getDoctorsStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .snapshots();
  }

  Future<String?> addDoctor({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String specialty,
    String? profileImage,
  }) async {
    _lastError = null;
    try {
      final secondaryAuth = await _getSecondaryAuth();
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;

      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'specialty': specialty.trim(),
        'role': 'doctor',
        'status': 'active',
        'patients': 0,
        'profileImage': profileImage,
        'isAvailable': true,
        'rating': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await secondaryAuth.signOut();

      debugPrint('✅ Doctor created successfully: $uid');

      return uid;
    } on FirebaseAuthException catch (e) {
      _lastError = e.code;
      debugPrint('❌ Error adding doctor (auth): ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('❌ Error adding doctor: $e');
      return null;
    }
  }

  Future<bool> updateDoctor(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _db.collection('users').doc(uid).update(data);

      debugPrint('✅ Doctor updated: $uid');

      return true;
    } catch (e) {
      debugPrint('❌ Error updating doctor: $e');
      return false;
    }
  }

  Future<bool> deleteDoctor(String uid) async {
    try {
      final assigned = await _db
          .collection('users')
          .where('assignedDoctorId', isEqualTo: uid)
          .limit(500)
          .get();

      final batch = _db.batch();
      for (final doc in assigned.docs) {
        batch.update(doc.reference, {
          'assignedDoctorId': FieldValue.delete(),
          'assignedDoctorName': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      batch.delete(_db.collection('users').doc(uid));
      await batch.commit();

      debugPrint('✅ Doctor deleted and assignments cleared: $uid');

      return true;
    } catch (e) {
      debugPrint('❌ Error deleting doctor: $e');
      return false;
    }
  }

  Future<void> updateDoctorWithImage({
    required String doctorId,
    String? specialty,
    String? phone,
    String? profileImage,
    String? status,
  }) async {
    final Map<String, dynamic> updates = {};

    if (specialty != null) updates['specialty'] = specialty;
    if (phone != null) updates['phone'] = phone;
    if (profileImage != null) updates['profileImage'] = profileImage;
    if (status != null) updates['status'] = status;

    updates['updatedAt'] = FieldValue.serverTimestamp();

    await _db.collection('users').doc(doctorId).update(updates);
  }

  // ══════════════════════════════════════════════════════════════
  // NURSES / INFIRMIÈRES
  // ══════════════════════════════════════════════════════════════

  Stream<QuerySnapshot> getNursesStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'nurse')
        .snapshots();
  }

  Future<String?> addNurse({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String department,
    required String shift,
    String? profileImage,
  }) async {
    _lastError = null;
    try {
      final secondaryAuth = await _getSecondaryAuth();
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;

      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'department': department.trim(),
        'shift': shift,
        'role': 'nurse',
        'status': 'active',
        'profileImage': profileImage,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await secondaryAuth.signOut();

      debugPrint('✅ Nurse created successfully: $uid');

      return uid;
    } on FirebaseAuthException catch (e) {
      _lastError = e.code;
      debugPrint('❌ Error adding nurse (auth): ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('❌ Error adding nurse: $e');
      return null;
    }
  }

  Future<bool> sendPasswordResetForUser(String email) async {
    _lastError = null;
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _lastError = e.code;
      debugPrint(
        '❌ Error sending password reset (auth): ${e.code} - ${e.message}',
      );
      return false;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('❌ Error sending password reset: $e');
      return false;
    }
  }

  Future<bool> setUserPasswordByAdmin({
    required String uid,
    required String newPassword,
  }) async {
    _lastError = null;
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('adminSetUserPassword');
      await callable.call({
        'uid': uid.trim(),
        'newPassword': newPassword,
      });
      return true;
    } on FirebaseFunctionsException catch (e) {
      _lastError = e.code;
      debugPrint(
        '❌ Error setting user password (functions): ${e.code} - ${e.message}',
      );
      return false;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('❌ Error setting user password: $e');
      return false;
    }
  }

  Future<bool> updateNurse(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _db.collection('users').doc(uid).update(data);

      debugPrint('✅ Nurse updated: $uid');

      return true;
    } catch (e) {
      debugPrint('❌ Error updating nurse: $e');
      return false;
    }
  }

  Future<bool> updateNurseWithImage({
    required String nurseId,
    String? department,
    String? phone,
    String? shift,
    String? profileImage,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (department != null) updates['department'] = department;
      if (phone != null) updates['phone'] = phone;
      if (shift != null) updates['shift'] = shift;
      if (profileImage != null) updates['profileImage'] = profileImage;
      if (status != null) updates['status'] = status;

      if (updates.isEmpty) return false;

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _db.collection('users').doc(nurseId).update(updates);

      debugPrint('✅ Nurse updated with image: $nurseId');

      return true;
    } catch (e) {
      debugPrint('❌ Error updating nurse with image: $e');
      return false;
    }
  }

  Future<bool> deleteNurse(String uid) async {
    try {
      await _db.collection('users').doc(uid).delete();

      debugPrint('✅ Nurse deleted: $uid');

      return true;
    } catch (e) {
      debugPrint('❌ Error deleting nurse: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // PATIENTS / PATIENTES
  // ══════════════════════════════════════════════════════════════

  Stream<QuerySnapshot> getPatientsStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .snapshots();
  }

  Stream<QuerySnapshot> getAllUsersStream() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<bool> updateUserRole({
    required String uid,
    required String role,
  }) async {
    try {
      await _db.collection('users').doc(uid).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error updating user role for $uid: $e');
      return false;
    }
  }

  Future<bool> updatePatient(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _db.collection('users').doc(uid).update(data);

      debugPrint('✅ Patient updated: $uid');

      return true;
    } catch (e) {
      debugPrint('❌ Error updating patient: $e');
      return false;
    }
  }

  Future<bool> updatePatientProfile({
    required String patientId,
    String? phone,
    String? wilaya,
    String? address,
    String? profileImage,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (phone != null) updates['phone'] = phone;
      if (wilaya != null) updates['wilaya'] = wilaya;
      if (address != null) updates['address'] = address;
      if (profileImage != null) updates['profileImage'] = profileImage;

      if (updates.isEmpty) return false;

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _db.collection('users').doc(patientId).update(updates);

      debugPrint('✅ Patient profile updated: $patientId');

      return true;
    } catch (e) {
      debugPrint('❌ Error updating patient profile: $e');
      return false;
    }
  }

  Future<bool> assignDoctorToPatient({
    required String patientId,
    required String doctorId,
    required String doctorName,
  }) async {
    try {
      await _db.runTransaction((transaction) async {
        final patientRef = _db.collection('users').doc(patientId);
        final newDoctorRef = _db.collection('users').doc(doctorId);

        final patientSnap = await transaction.get(patientRef);
        if (!patientSnap.exists) {
          throw Exception('Patient document not found');
        }
        final pdata = patientSnap.data()!;
        if (pdata['role'] != 'patient') {
          throw Exception('Target user is not a patient');
        }

        final oldId = pdata['assignedDoctorId'] as String?;
        if (oldId == doctorId) {
          return;
        }

        if (oldId != null && oldId.isNotEmpty) {
          final oldDoctorRef = _db.collection('users').doc(oldId);
          final oldDoctorSnap = await transaction.get(oldDoctorRef);
          if (oldDoctorSnap.exists) {
            transaction.update(oldDoctorRef, {
              'patients': FieldValue.increment(-1),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }

        transaction.update(patientRef, {
          'assignedDoctorId': doctorId,
          'assignedDoctorName': doctorName,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(newDoctorRef, {
          'patients': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      debugPrint(
        '✅ Doctor $doctorName assigned to patient $patientId',
      );

      return true;
    } catch (e) {
      debugPrint('❌ Error assigning doctor: $e');
      return false;
    }
  }

  /// Removes the patient’s attending doctor and decrements that doctor’s [patients] counter.
  Future<bool> unassignDoctorFromPatient(String patientId) async {
    try {
      await _db.runTransaction((transaction) async {
        final patientRef = _db.collection('users').doc(patientId);
        final patientSnap = await transaction.get(patientRef);
        if (!patientSnap.exists) return;
        final oldId = patientSnap.data()!['assignedDoctorId'] as String?;
        if (oldId == null || oldId.isEmpty) return;

        final doctorRef = _db.collection('users').doc(oldId);
        final doctorSnap = await transaction.get(doctorRef);
        if (doctorSnap.exists) {
          transaction.update(doctorRef, {
            'patients': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        transaction.update(patientRef, {
          'assignedDoctorId': FieldValue.delete(),
          'assignedDoctorName': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error unassigning doctor: $e');
      return false;
    }
  }

  Future<bool> setDoctorAvailability({
    required String doctorId,
    required bool isAvailable,
  }) async {
    try {
      await _db.collection('users').doc(doctorId).update({
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error updating doctor availability: $e');
      return false;
    }
  }

  Stream<DocumentSnapshot> watchDoctor(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Future<bool> deletePatient(String uid) async {
    try {
      await _db.collection('users').doc(uid).delete();

      debugPrint('✅ Patient deleted: $uid');

      return true;
    } catch (e) {
      debugPrint('❌ Error deleting patient: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // BABIES MANAGEMENT
  // ══════════════════════════════════════════════════════════════

  Future<String> addBaby({
    required String motherId,
    required String firstName,
    required String lastName,
    required String gender,
    required DateTime birthDate,
    double? weight,
    double? height,
    String? notes,
  }) async {
    try {
      final babyRef = await _db.collection('babies').add({
        'motherId': motherId,
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'gender': gender,
        'birthDate': Timestamp.fromDate(birthDate),
        'weight': weight,
        'height': height,
        'healthStatus': 'healthy',
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _db.collection('users').doc(motherId).update({
        'babies': FieldValue.arrayUnion([babyRef.id]),
      });

      return babyRef.id;
    } catch (e) {
      debugPrint('❌ Error adding baby: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getBabiesStream(String motherId) {
    return _db
        .collection('babies')
        .where('motherId', isEqualTo: motherId)
        .snapshots();
  }

  Stream<QuerySnapshot> getAssignedPatientsStream(String doctorId) {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .where('assignedDoctorId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateBaby(
    String babyId,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('babies').doc(babyId).update(data);
  }

  Future<void> deleteBaby(
    String babyId,
    String motherId,
  ) async {
    await _db.collection('users').doc(motherId).update({
      'babies': FieldValue.arrayRemove([babyId]),
    });

    await _db.collection('babies').doc(babyId).delete();
  }

  // ══════════════════════════════════════════════════════════════
  // ROOMS / CHAMBRES
  // ══════════════════════════════════════════════════════════════

  Stream<QuerySnapshot> getRoomsStream() {
    return _db
        .collection('rooms')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<String?> addRoom({
    required String number,
    required String type,
    required int floor,
    required int capacity,
  }) async {
    try {
      final roomRef = await _db.collection('rooms').add({
        'number': number.trim(),
        'type': type,
        'floor': floor,
        'capacity': capacity,
        'status': 'available',
        'patientName': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Room created: ${roomRef.id}');

      return roomRef.id;
    } catch (e) {
      debugPrint('❌ Error adding room: $e');
      return null;
    }
  }

  Future<bool> updateRoom(
    String roomId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _db.collection('rooms').doc(roomId).update(data);

      debugPrint('✅ Room updated: $roomId');

      return true;
    } catch (e) {
      debugPrint('❌ Error updating room: $e');
      return false;
    }
  }

  Future<bool> deleteRoom(String roomId) async {
    try {
      await _db.collection('rooms').doc(roomId).delete();

      debugPrint('✅ Room deleted: $roomId');

      return true;
    } catch (e) {
      debugPrint('❌ Error deleting room: $e');
      return false;
    }
  }

  Stream<QuerySnapshot> getContactsStream() {
    return _db
        .collection('users')
        .where('role', whereIn: ['doctor', 'nurse', 'patient'])
        .snapshots();
  }

  Stream<QuerySnapshot> getMessagesStream(String contactId) {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null) {
      return const Stream.empty();
    }
    final ids = [myUid, contactId]..sort();
    final chatId = '${ids[0]}_${ids[1]}';
    return _db
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .snapshots();
  }

  Future<void> sendMessage(String contactId, String text) async {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null) return;
    final ids = [myUid, contactId]..sort();
    final chatId = '${ids[0]}_${ids[1]}';

    await _db.collection('messages').add({
      'senderId': myUid,
      'receiverId': contactId,
      'chatId': chatId,
      'participants': [myUid, contactId],
      'text': text,
      'seen': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<int> getUnreadCountStream(String contactId) {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null) return Stream<int>.value(0);
    return _db
        .collection('messages')
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
        .collection('messages')
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

  Stream<int> getTotalUnreadMessagesStream() {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null) return Stream<int>.value(0);
    return _db
        .collection('messages')
        .where('receiverId', isEqualTo: myUid)
        .where('seen', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  Stream<QuerySnapshot> getEmergencyAlertsStream() {
    return _db
        .collection('emergency_alerts')
        .orderBy('alertTime', descending: true)
        .snapshots();
  }

  Future<void> resolveEmergencyAlert(String alertId) async {
    await _db.collection('emergency_alerts').doc(alertId).update({
      'status': 'resolved',
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> notifyDoctorForAlert(String alertId) async {
    await _db.collection('emergency_alerts').doc(alertId).update({
      'doctorNotified': true,
      'doctorNotifiedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> callNurseForAlert(String alertId) async {
    await _db.collection('emergency_alerts').doc(alertId).update({
      'nurseCalled': true,
      'nurseCalledAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getPregnancyMonitoringStream(String patientId) {
    return _db
        .collection('pregnancy_monitoring')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getMedicalRecordsStream(String patientId) {
    return _db
        .collection('medical_records')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
