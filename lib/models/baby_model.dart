import 'package:cloud_firestore/cloud_firestore.dart';

class BabyModel {
  final String id;
  final String motherId; // معرّف الأم
  final String firstName;
  final String lastName;
  final String gender; // male, female
  final DateTime birthDate;
  final double? weight; // الوزن بالكيلوغرام
  final double? height; // الطول بالسنتيمتر
  final String healthStatus; // healthy, needs_care, critical
  final String? notes;
  final String? photoUrl;
  final DateTime createdAt;

  BabyModel({
    required this.id,
    required this.motherId,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthDate,
    this.weight,
    this.height,
    this.healthStatus = 'healthy',
    this.notes,
    this.photoUrl,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  String get genderLabel {
    switch (gender) {
      case 'male':
        return 'ذكر / Garçon';
      case 'female':
        return 'أنثى / Fille';
      default:
        return 'غير محدد';
    }
  }

  factory BabyModel.fromMap(Map<String, dynamic> map, String id) {
    return BabyModel(
      id: id,
      motherId: map['motherId'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      gender: map['gender'] ?? 'male',
      birthDate: (map['birthDate'] as Timestamp).toDate(),
      weight: map['weight']?.toDouble(),
      height: map['height']?.toDouble(),
      healthStatus: map['healthStatus'] ?? 'healthy',
      notes: map['notes'],
      photoUrl: map['photoUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'motherId': motherId,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'birthDate': Timestamp.fromDate(birthDate),
      'weight': weight,
      'height': height,
      'healthStatus': healthStatus,
      'notes': notes,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
