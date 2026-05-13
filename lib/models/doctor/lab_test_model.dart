import 'package:cloud_firestore/cloud_firestore.dart';

class LabTestModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final String category;
  final String testName;
  final String value;
  final String status;
  final DateTime testDate;
  final String? pdfUrl;

  LabTestModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.category,
    required this.testName,
    required this.value,
    required this.status,
    required this.testDate,
    this.pdfUrl,
  });

  factory LabTestModel.fromDoc(String id, Map<String, dynamic> map) {
    return LabTestModel(
      id: id,
      doctorId: map['doctorId'] as String? ?? '',
      patientId: map['patientId'] as String? ?? '',
      patientName: map['patientName'] as String? ?? '',
      category: map['category'] as String? ?? 'blood',
      testName: map['testName'] as String? ?? '',
      value: map['value']?.toString() ?? '',
      status: map['status'] as String? ?? 'normal',
      testDate: map['testDate'] != null
          ? (map['testDate'] as Timestamp).toDate()
          : DateTime.now(),
      pdfUrl: map['pdfUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'patientName': patientName,
      'category': category,
      'testName': testName,
      'result': value,
      'value': value,
      'unit': '',
      'status': status,
      'date': Timestamp.fromDate(testDate),
      'testDate': Timestamp.fromDate(testDate),
      'fileUrl': pdfUrl,
      'pdfUrl': pdfUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
