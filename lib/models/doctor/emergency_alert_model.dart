import 'package:cloud_firestore/cloud_firestore.dart';

/// Aligns with `emergency_alerts` docs (see admin / patients_screen).
class EmergencyAlertModel {
  final String id;
  final String patientId;
  final String patientName;
  final String? roomNumber;
  final String severity;
  final String status;
  final DateTime? alertTime;
  final String? reason;

  EmergencyAlertModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.roomNumber,
    this.severity = 'high',
    this.status = 'open',
    this.alertTime,
    this.reason,
  });

  bool get isOpen {
    final s = status.toLowerCase();
    return s == 'open' || s == 'pending' || s == 'active';
  }

  factory EmergencyAlertModel.fromDoc(
    String id,
    Map<String, dynamic> map,
  ) {
    return EmergencyAlertModel(
      id: id,
      patientId: map['patientId'] as String? ?? '',
      patientName: map['patientName'] as String? ?? '',
      roomNumber: map['roomNumber'] as String?,
      severity: map['severity'] as String? ?? 'high',
      status: map['status'] as String? ?? 'open',
      alertTime: map['alertTime'] != null
          ? (map['alertTime'] as Timestamp).toDate()
          : null,
      reason: map['reason'] as String?,
    );
  }
}
