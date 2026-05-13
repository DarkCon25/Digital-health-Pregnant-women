import 'package:cloud_firestore/cloud_firestore.dart';

class AnalysisModel {
  final String id;
  final String patientId;
  final String testName;
  final String result;
  final String unit;
  final String category; // blood | urine | other
  final String status; // normal | low | high | critical
  final DateTime date;
  final String? fileUrl;
  final String? fileName;

  AnalysisModel({
    required this.id,
    required this.patientId,
    required this.testName,
    required this.result,
    required this.unit,
    required this.category,
    required this.status,
    required this.date,
    this.fileUrl,
    this.fileName,
  });

  factory AnalysisModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final rawDate = d['date'] ?? d['testDate'] ?? d['createdAt'];
    final rawStatus = (d['status'] as String? ?? 'normal').toLowerCase();
    final normalizedStatus = rawStatus == 'abnormal' ? 'high' : rawStatus;
    return AnalysisModel(
      id: doc.id,
      patientId: d['patientId'] as String? ?? '',
      testName: d['testName'] as String? ?? '',
      result: (d['result'] ?? d['value'])?.toString() ?? '',
      unit: d['unit'] as String? ?? '',
      category: d['category'] as String? ?? 'other',
      status: normalizedStatus,
      date: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
      fileUrl: (d['fileUrl'] ?? d['pdfUrl']) as String?,
      fileName: (d['fileName'] ?? d['pdfName']) as String?,
    );
  }
}
