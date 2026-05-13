import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyAlertModel {
  final String id;
  final String patientId;
  final String patientName;
  final String? roomNumber;
  final String? latitude;
  final String? longitude;
  final String status; // open | resolved
  final DateTime createdAt;

  EmergencyAlertModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.roomNumber,
    this.latitude,
    this.longitude,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'patientName': patientName,
        'roomNumber': roomNumber,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
        'severity': 'high',
        'priority': 'high',
        'reason': 'Emergency alert from patient app',
        'description': 'Emergency alert from patient app',
        'alertTime': Timestamp.fromDate(createdAt),
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
