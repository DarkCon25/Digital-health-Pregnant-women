import 'package:cloud_firestore/cloud_firestore.dart';

class FetalImageModel {
  final String id;
  final String patientId;
  final String imageUrl;
  final String? thumbnailUrl;
  final int weekNumber;
  final DateTime date;
  final String? notes;

  FetalImageModel({
    required this.id,
    required this.patientId,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.weekNumber,
    required this.date,
    this.notes,
  });

  factory FetalImageModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final rawWeek = d['weekNumber'];
    final label = d['sessionLabel']?.toString() ?? '';
    final weekFromLabel = RegExp(r'\d+').firstMatch(label)?.group(0);
    final rawDate = d['date'] ?? d['createdAt'];
    return FetalImageModel(
      id: doc.id,
      patientId: d['patientId'] as String? ?? '',
      imageUrl: d['imageUrl'] as String? ?? '',
      thumbnailUrl: (d['thumbnailUrl'] ?? d['imageUrl']) as String?,
      weekNumber: (rawWeek as num?)?.toInt() ??
          int.tryParse(weekFromLabel ?? '') ??
          0,
      date: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
      notes: (d['notes'] ?? d['sessionLabel']) as String?,
    );
  }
}
