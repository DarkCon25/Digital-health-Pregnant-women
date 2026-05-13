import 'package:cloud_firestore/cloud_firestore.dart';

/// Latest vitals + counters stored at `medical_files/{patientId}`.
class MedicalFileModel {
  final String patientId;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final int? heartRateBpm;
  final int? fetalHeartRateBpm;
  /// Blood glucose (g/L display; stored as double).
  final double? bloodGlucose;
  /// Celsius
  final double? temperatureCelsius;
  final int visitCount;
  final DateTime? lastVisitAt;
  final DateTime updatedAt;

  MedicalFileModel({
    required this.patientId,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.heartRateBpm,
    this.fetalHeartRateBpm,
    this.bloodGlucose,
    this.temperatureCelsius,
    this.visitCount = 0,
    this.lastVisitAt,
    required this.updatedAt,
  });

  factory MedicalFileModel.empty(String patientId) {
    return MedicalFileModel(
      patientId: patientId,
      updatedAt: DateTime.now(),
    );
  }

  factory MedicalFileModel.fromDoc(
    String patientId,
    Map<String, dynamic> map,
  ) {
    return MedicalFileModel(
      patientId: patientId,
      bloodPressureSystolic: map['bloodPressureSystolic'] as int?,
      bloodPressureDiastolic: map['bloodPressureDiastolic'] as int?,
      heartRateBpm: map['heartRateBpm'] as int?,
      fetalHeartRateBpm: map['fetalHeartRateBpm'] as int?,
      bloodGlucose: (map['bloodGlucose'] as num?)?.toDouble(),
      temperatureCelsius: (map['temperatureCelsius'] as num?)?.toDouble(),
      visitCount: (map['visitCount'] as int?) ?? 0,
      lastVisitAt: map['lastVisitAt'] != null
          ? (map['lastVisitAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'bloodPressureSystolic': bloodPressureSystolic,
      'bloodPressureDiastolic': bloodPressureDiastolic,
      'heartRateBpm': heartRateBpm,
      'fetalHeartRateBpm': fetalHeartRateBpm,
      'bloodGlucose': bloodGlucose,
      'temperatureCelsius': temperatureCelsius,
      'visitCount': visitCount,
      'lastVisitAt':
          lastVisitAt != null ? Timestamp.fromDate(lastVisitAt!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  MedicalFileModel copyWith({
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? heartRateBpm,
    int? fetalHeartRateBpm,
    double? bloodGlucose,
    double? temperatureCelsius,
    int? visitCount,
    DateTime? lastVisitAt,
    DateTime? updatedAt,
  }) {
    return MedicalFileModel(
      patientId: patientId,
      bloodPressureSystolic:
          bloodPressureSystolic ?? this.bloodPressureSystolic,
      bloodPressureDiastolic:
          bloodPressureDiastolic ?? this.bloodPressureDiastolic,
      heartRateBpm: heartRateBpm ?? this.heartRateBpm,
      fetalHeartRateBpm: fetalHeartRateBpm ?? this.fetalHeartRateBpm,
      bloodGlucose: bloodGlucose ?? this.bloodGlucose,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      visitCount: visitCount ?? this.visitCount,
      lastVisitAt: lastVisitAt ?? this.lastVisitAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
