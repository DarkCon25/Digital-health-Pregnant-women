import 'package:cloud_firestore/cloud_firestore.dart';

/// Nurse-facing emergency item (wraps `emergency_alerts` schema).
class EmergencyRequestModel {
  EmergencyRequestModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.roomNumber,
    this.severity = 'high',
    this.status = 'open',
    this.alertTime,
    this.reason,
  });

  final String id;
  final String patientId;
  final String patientName;
  final String? roomNumber;
  final String severity;
  final String status;
  final DateTime? alertTime;
  final String? reason;

  bool get isOpen {
    final s = status.toLowerCase();
    return s == 'open' || s == 'pending' || s == 'active';
  }

  factory EmergencyRequestModel.fromDoc(String id, Map<String, dynamic> m) {
    return EmergencyRequestModel(
      id: id,
      patientId: m['patientId'] as String? ?? '',
      patientName: m['patientName'] as String? ?? '',
      roomNumber: m['roomNumber'] as String?,
      severity: m['severity'] as String? ?? 'high',
      status: m['status'] as String? ?? 'open',
      alertTime: m['alertTime'] is Timestamp
          ? (m['alertTime'] as Timestamp).toDate()
          : null,
      reason: m['reason'] as String?,
    );
  }
}
