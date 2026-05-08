import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// ════════════════════════════════════════════════════════════════
// HerCare - Admin Service (Complete & Secure)
// Service Admin (Complet et sécurisé)
// ════════════════════════════════════════════════════════════════

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Secondary Auth Instance for creating users without logout
  late final FirebaseAuth _secondaryAuth;

  AdminService() {
    try {
      _secondaryAuth = FirebaseAuth.instanceFor(app: _auth.app);
    } catch (e) {
      _secondaryAuth = _auth;
      debugPrint('⚠️ Secondary Auth not available, using primary');
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
        .orderBy('createdAt', descending: true)
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
    try {
      final credential = await _secondaryAuth.createUserWithEmailAndPassword(
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

      await _secondaryAuth.signOut();

      debugPrint('✅ Doctor created successfully: $uid');

      return uid;
    } catch (e) {
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
      await _db.collection('users').doc(uid).delete();

      debugPrint('✅ Doctor deleted: $uid');

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
        .orderBy('createdAt', descending: true)
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
    try {
      final credential = await _secondaryAuth.createUserWithEmailAndPassword(
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

      await _secondaryAuth.signOut();

      debugPrint('✅ Nurse created successfully: $uid');

      return uid;
    } catch (e) {
      debugPrint('❌ Error adding nurse: $e');
      return null;
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
        .orderBy('createdAt', descending: true)
        .snapshots();
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
      await _db.collection('users').doc(patientId).update({
        'assignedDoctorId': doctorId,
        'assignedDoctorName': doctorName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _db.collection('users').doc(doctorId).update({
        'patients': FieldValue.increment(1),
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
        .orderBy('birthDate', descending: true)
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
}
