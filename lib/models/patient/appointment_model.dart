import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String? patientName;
  final String doctorId;
  final String doctorName;
  final String type;
  final DateTime dateTime;
  final String status; // confirmed | pending | completed | cancelled
  final String? notes;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.patientId,
    this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.type,
    required this.dateTime,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final rawDate = d['dateTime'] ?? d['startAt'] ?? d['createdAt'];
    return AppointmentModel(
      id: doc.id,
      patientId: d['patientId'] as String? ?? '',
      patientName: d['patientName'] as String?,
      doctorId: d['doctorId'] as String? ?? '',
      doctorName: d['doctorName'] as String? ?? '',
      type: d['type'] as String? ?? '',
      dateTime: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
      status: d['status'] as String? ?? 'pending',
      notes: d['notes'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'type': type,
        'dateTime': Timestamp.fromDate(dateTime),
        'startAt': Timestamp.fromDate(dateTime),
        'status': status,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
