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
  final int respiratoryRate;
  final int? oxygenSaturationPercent;
  final int visitCount;
  final DateTime? lastVisitAt;
  final DateTime updatedAt;
  final String? deliveryType; // natural, caesarean, underCare
  final DateTime? deliveryDate;
  final String? deliveryStatus; // in_progress, completed, complicated
  final DateTime? lastNurseVitalsAt;

  MedicalFileModel({
    required this.patientId,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.heartRateBpm,
    this.fetalHeartRateBpm,
    this.bloodGlucose,
    this.temperatureCelsius,
    this.respiratoryRate = 0,
    this.oxygenSaturationPercent,
    this.visitCount = 0,
    this.lastVisitAt,
    required this.updatedAt,
    this.deliveryType,
    this.deliveryDate,
    this.deliveryStatus,
    this.lastNurseVitalsAt,
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
      respiratoryRate: (map['respiratoryRate'] as int?) ?? 0,
      oxygenSaturationPercent: map['oxygenSaturationPercent'] as int?,
      visitCount: (map['visitCount'] as int?) ?? 0,
      lastVisitAt: map['lastVisitAt'] != null
          ? (map['lastVisitAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      deliveryType: map['deliveryType'],
      deliveryDate: map['deliveryDate'] != null
          ? (map['deliveryDate'] as Timestamp).toDate()
          : null,
      deliveryStatus: map['deliveryStatus'],
      lastNurseVitalsAt: map['lastNurseVitalsAt'] != null
          ? (map['lastNurseVitalsAt'] as Timestamp).toDate()
          : null,
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
      'respiratoryRate': respiratoryRate,
      'oxygenSaturationPercent': oxygenSaturationPercent,
      'visitCount': visitCount,
      'lastVisitAt':
          lastVisitAt != null ? Timestamp.fromDate(lastVisitAt!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
      'deliveryType': deliveryType,
      'deliveryDate':
          deliveryDate != null ? Timestamp.fromDate(deliveryDate!) : null,
      'deliveryStatus': deliveryStatus,
      'lastNurseVitalsAt': lastNurseVitalsAt != null
          ? Timestamp.fromDate(lastNurseVitalsAt!)
          : null,
    };
  }

  MedicalFileModel copyWith({
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? heartRateBpm,
    int? fetalHeartRateBpm,
    double? bloodGlucose,
    double? temperatureCelsius,
    int? respiratoryRate,
    int? oxygenSaturationPercent,
    int? visitCount,
    DateTime? lastVisitAt,
    DateTime? updatedAt,
    String? deliveryType,
    DateTime? deliveryDate,
    String? deliveryStatus,
    DateTime? lastNurseVitalsAt,
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
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      oxygenSaturationPercent:
          oxygenSaturationPercent ?? this.oxygenSaturationPercent,
      visitCount: visitCount ?? this.visitCount,
      lastVisitAt: lastVisitAt ?? this.lastVisitAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveryType: deliveryType ?? this.deliveryType,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      lastNurseVitalsAt: lastNurseVitalsAt ?? this.lastNurseVitalsAt,
    );
  }
}
