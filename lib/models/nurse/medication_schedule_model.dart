import 'package:cloud_firestore/cloud_firestore.dart';

/// `medication_schedules` document.
class MedicationScheduleModel {
  MedicationScheduleModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.medicationName,
    required this.dosage,
    required this.route,
    required this.scheduledAt,
    this.status = 'pending',
    this.administeredAt,
    this.nurseId,
    this.nurseName,
  });

  final String id;
  final String patientId;
  final String patientName;
  final String medicationName;
  final String dosage;
  final String route;
  final DateTime scheduledAt;
  final String status;
  final DateTime? administeredAt;
  final String? nurseId;
  final String? nurseName;

  bool get isAdministered => status.toLowerCase() == 'administered';

  factory MedicationScheduleModel.fromDoc(String id, Map<String, dynamic> m) {
    return MedicationScheduleModel(
      id: id,
      patientId: m['patientId'] as String? ?? '',
      patientName: m['patientName'] as String? ?? '',
      medicationName: m['medicationName'] as String? ?? '',
      dosage: m['dosage'] as String? ?? '',
      route: m['route'] as String? ?? 'oral',
      scheduledAt: m['scheduledAt'] is Timestamp
          ? (m['scheduledAt'] as Timestamp).toDate()
          : DateTime.now(),
      status: m['status'] as String? ?? 'pending',
      administeredAt: m['administeredAt'] is Timestamp
          ? (m['administeredAt'] as Timestamp).toDate()
          : null,
      nurseId: m['nurseId'] as String?,
      nurseName: m['nurseName'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'medicationName': medicationName,
      'dosage': dosage,
      'route': route,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'status': status,
      'administeredAt':
          administeredAt != null ? Timestamp.fromDate(administeredAt!) : null,
      'nurseId': nurseId,
      'nurseName': nurseName,
    };
  }
}
