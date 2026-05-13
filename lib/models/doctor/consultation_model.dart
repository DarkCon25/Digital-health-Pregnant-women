import 'package:cloud_firestore/cloud_firestore.dart';

/// One consultation note under `medical_files/{patientId}/consultations`.
class ConsultationModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String notes;
  final String? diagnosis;
  final DateTime visitDate;
  final DateTime createdAt;

  ConsultationModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.notes,
    this.diagnosis,
    required this.visitDate,
    required this.createdAt,
  });

  factory ConsultationModel.fromDoc(
    String id,
    Map<String, dynamic> map,
  ) {
    return ConsultationModel(
      id: id,
      patientId: map['patientId'] as String? ?? '',
      doctorId: map['doctorId'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      diagnosis: map['diagnosis'] as String?,
      visitDate: map['visitDate'] != null
          ? (map['visitDate'] as Timestamp).toDate()
          : DateTime.now(),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'notes': notes,
      'diagnosis': diagnosis,
      'visitDate': Timestamp.fromDate(visitDate),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class DoctorAppointmentModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final DateTime startAt;
  final String status;
  final String? notes;

  DoctorAppointmentModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.startAt,
    this.status = 'scheduled',
    this.notes,
  });

  factory DoctorAppointmentModel.fromDoc(
    String id,
    Map<String, dynamic> map,
  ) {
    final rawStart = map['startAt'] ?? map['dateTime'] ?? map['createdAt'];
    return DoctorAppointmentModel(
      id: id,
      doctorId: map['doctorId'] as String? ?? '',
      patientId: map['patientId'] as String? ?? '',
      patientName: map['patientName'] as String? ?? '',
      startAt: rawStart is Timestamp ? rawStart.toDate() : DateTime.now(),
      status: map['status'] as String? ?? 'pending',
      notes: map['notes'] as String?,
    );
  }
}
