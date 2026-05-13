import 'package:cloud_firestore/cloud_firestore.dart';

class UltrasoundImageModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String imageUrl;
  final String? sessionLabel;
  final DateTime createdAt;

  UltrasoundImageModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.imageUrl,
    this.sessionLabel,
    required this.createdAt,
  });

  factory UltrasoundImageModel.fromDoc(String id, Map<String, dynamic> map) {
    final rawCreated = map['createdAt'] ?? map['date'];
    return UltrasoundImageModel(
      id: id,
      patientId: map['patientId'] as String? ?? '',
      doctorId: map['doctorId'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      sessionLabel: map['sessionLabel'] as String?,
      createdAt: rawCreated is Timestamp ? rawCreated.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'imageUrl': imageUrl,
      'sessionLabel': sessionLabel,
      'notes': sessionLabel,
      'date': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
