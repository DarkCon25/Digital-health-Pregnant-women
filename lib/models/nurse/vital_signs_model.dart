import 'package:cloud_firestore/cloud_firestore.dart';

/// Snapshot of vitals (aligned with `medical_files` + optional nurse fields).
class VitalSignsModel {
  VitalSignsModel({
    required this.patientId,
    this.systolic,
    this.diastolic,
    this.heartRateBpm,
    this.respiratoryRate,
    this.oxygenSaturationPercent,
    this.temperatureCelsius,
    this.bloodGlucose,
    this.updatedAt,
  });

  final String patientId;
  final int? systolic;
  final int? diastolic;
  final int? heartRateBpm;
  final int? respiratoryRate;
  final int? oxygenSaturationPercent;
  final double? temperatureCelsius;
  final double? bloodGlucose;
  final DateTime? updatedAt;

  factory VitalSignsModel.fromMedicalFileMap(
    String patientId,
    Map<String, dynamic> map,
  ) {
    return VitalSignsModel(
      patientId: patientId,
      systolic: map['bloodPressureSystolic'] as int?,
      diastolic: map['bloodPressureDiastolic'] as int?,
      heartRateBpm: map['heartRateBpm'] as int?,
      respiratoryRate: map['respiratoryRate'] as int?,
      oxygenSaturationPercent: map['oxygenSaturationPercent'] as int?,
      temperatureCelsius: (map['temperatureCelsius'] as num?)?.toDouble(),
      bloodGlucose: (map['bloodGlucose'] as num?)?.toDouble(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestoreMerge() {
    return {
      'patientId': patientId,
      'bloodPressureSystolic': systolic,
      'bloodPressureDiastolic': diastolic,
      'heartRateBpm': heartRateBpm,
      'respiratoryRate': respiratoryRate,
      'oxygenSaturationPercent': oxygenSaturationPercent,
      'temperatureCelsius': temperatureCelsius,
      'bloodGlucose': bloodGlucose,
      'updatedAt': FieldValue.serverTimestamp(),
      'lastNurseVitalsAt': FieldValue.serverTimestamp(),
    };
  }
}
