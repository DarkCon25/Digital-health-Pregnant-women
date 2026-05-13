import '../patient_model.dart';

/// Patient row for nurse workflows (wraps [PatientModel] + optional ward fields).
class NursePatientModel {
  NursePatientModel({
    required this.patient,
    this.deliveryType,
    this.careNeeded = false,
  });

  final PatientModel patient;
  final String? deliveryType;
  final bool careNeeded;

  String get id => patient.uid;
  String get fullName => patient.fullName;
  String? get roomNumber => patient.roomNumber;
  String get status => patient.status;

  int? get pregnancyMonth {
    final w = patient.gestationalWeek ?? patient.pregnancyWeek;
    if (w == null) return null;
    return (w / 4).ceil().clamp(1, 10);
  }

  factory NursePatientModel.fromMap(Map<String, dynamic> map) {
    return NursePatientModel(
      patient: PatientModel.fromMap(map),
      deliveryType: map['deliveryType'] as String?,
      careNeeded: map['careNeeded'] == true,
    );
  }
}
