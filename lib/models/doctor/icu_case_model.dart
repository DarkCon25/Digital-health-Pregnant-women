import 'package:cloud_firestore/cloud_firestore.dart';

class IcuCaseModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final String reason;
  final DateTime? admittedAt;
  final String status;

  IcuCaseModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.reason,
    this.admittedAt,
    this.status = 'active',
  });

  bool get isActive {
    final s = status.toLowerCase();
    return s == 'active' || s == 'critical' || s == 'monitoring';
  }

  factory IcuCaseModel.fromDoc(String id, Map<String, dynamic> map) {
    return IcuCaseModel(
      id: id,
      doctorId: map['doctorId'] as String? ?? '',
      patientId: map['patientId'] as String? ?? '',
      patientName: map['patientName'] as String? ?? '',
      reason: map['reason'] as String? ?? '',
      admittedAt: map['admittedAt'] != null
          ? (map['admittedAt'] as Timestamp).toDate()
          : null,
      status: map['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'patientName': patientName,
      'reason': reason,
      'admittedAt': Timestamp.fromDate(
        admittedAt ?? DateTime.now(),
      ),
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
