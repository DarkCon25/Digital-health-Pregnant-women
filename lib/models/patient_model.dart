import 'package:cloud_firestore/cloud_firestore.dart';

// ════════════════════════════════════════════════════════════════
// HerCare - Patient Model (Pregnant Woman)
// Modèle Patiente (Femme enceinte)
// نموذج المريضة (الحامل)
// ════════════════════════════════════════════════════════════════

class PatientModel {
  // ── Basic Information / Informations de base / المعلومات الأساسية
  final String uid;
  final String firstName; // Prénom / الاسم
  final String lastName; // Nom / اللقب
  final String email;
  final String phone; // Téléphone / الهاتف

  // ── Location / Localisation / الموقع
  final String wilaya; // Province / Wilaya / الولاية
  final String? address; // Full address / Adresse complète / العنوان الكامل

  // ── Medical Status / Statut médical / الحالة الطبية
  final String status; // active / stable / critical / inactive
  final String? bloodType; // Blood type / Groupe sanguin / فصيلة الدم
  final DateTime?
      dateOfBirth; // Date of birth / Date de naissance / تاريخ الميلاد

  // ── Pregnancy Information / Informations grossesse / معلومات الحمل
  final int?
      pregnancyWeek; // Pregnancy week / Semaine de grossesse / أسبوع الحمل
  final int?
      gestationalWeek; // Gestational week / Semaine gestationnelle / الأسبوع الحملي
  final DateTime?
      lastMenstrualPeriod; // LMP / Dernières règles / آخر دورة شهرية
  final DateTime?
      expectedDeliveryDate; // EDD / Date prévue d'accouchement / الموعد المتوقع للولادة

  // ── Assigned Medical Staff / Personnel médical assigné / الطاقم الطبي المخصص
  final String? assignedDoctorId; // Doctor ID / ID médecin / معرف الطبيب
  final String? assignedDoctorName; // Doctor name / Nom médecin / اسم الطبيب
  final String?
      assignedDoctor; // Legacy field / Champ hérité / حقل قديم (للتوافق)

  // ── Hospital Room / Chambre / الغرفة
  final String? roomNumber; // Room number / Numéro de chambre / رقم الغرفة

  // ── Profile & Media / Profil et médias / الملف الشخصي
  final String?
      profileImage; // Profile photo / Photo de profil / الصورة الشخصية

  // ── Babies / Bébés / المواليد
  final List<String> babies; // Baby IDs / IDs des bébés / معرفات المواليد

  // ── Metadata / Métadonnées / البيانات الوصفية
  final DateTime createdAt; // Creation date / Date de création / تاريخ الإنشاء
  final DateTime? updatedAt; // Last update / Dernière mise à jour / آخر تحديث

  PatientModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.wilaya,
    this.address,
    this.status = 'active',
    this.bloodType,
    this.dateOfBirth,
    this.pregnancyWeek,
    this.gestationalWeek,
    this.lastMenstrualPeriod,
    this.expectedDeliveryDate,
    this.assignedDoctorId,
    this.assignedDoctorName,
    this.assignedDoctor,
    this.roomNumber,
    this.profileImage,
    this.babies = const [],
    required this.createdAt,
    this.updatedAt,
  });

  // ════════════════════════════════════════════════════════════════
  // FACTORY METHODS / MÉTHODES FACTORY / دوال الإنشاء
  // ════════════════════════════════════════════════════════════════

  /// Create from Firestore document
  /// Créer depuis un document Firestore
  /// إنشاء من وثيقة Firestore
  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      wilaya: map['wilaya'] ?? '',
      address: map['address'],
      status: map['status'] ?? 'active',
      bloodType: map['bloodType'],
      dateOfBirth: map['dateOfBirth'] != null
          ? (map['dateOfBirth'] as Timestamp).toDate()
          : null,
      pregnancyWeek: map['pregnancyWeek'],
      gestationalWeek: map['gestationalWeek'],
      lastMenstrualPeriod: map['lastMenstrualPeriod'] != null
          ? (map['lastMenstrualPeriod'] as Timestamp).toDate()
          : null,
      expectedDeliveryDate: map['expectedDeliveryDate'] != null
          ? (map['expectedDeliveryDate'] as Timestamp).toDate()
          : null,
      assignedDoctorId: map['assignedDoctorId'],
      assignedDoctorName: map['assignedDoctorName'],
      assignedDoctor: map['assignedDoctor'],
      roomNumber: map['roomNumber'],
      profileImage: map['profileImage'],
      babies: List<String>.from(map['babies'] ?? []),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert to Firestore document
  /// Convertir en document Firestore
  /// تحويل إلى وثيقة Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'wilaya': wilaya,
      'address': address,
      'role': 'patient',
      'status': status,
      'bloodType': bloodType,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'pregnancyWeek': pregnancyWeek,
      'gestationalWeek': gestationalWeek,
      'lastMenstrualPeriod': lastMenstrualPeriod != null
          ? Timestamp.fromDate(lastMenstrualPeriod!)
          : null,
      'expectedDeliveryDate': expectedDeliveryDate != null
          ? Timestamp.fromDate(expectedDeliveryDate!)
          : null,
      'assignedDoctorId': assignedDoctorId,
      'assignedDoctorName': assignedDoctorName,
      'assignedDoctor': assignedDoctor,
      'roomNumber': roomNumber,
      'profileImage': profileImage,
      'babies': babies,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // ════════════════════════════════════════════════════════════════
  // GETTERS / ACCESSEURS / الحقول المحسوبة
  // ════════════════════════════════════════════════════════════════

  /// Full name / Nom complet / الاسم الكامل
  String get fullName => '$firstName $lastName';

  /// Status label / Libellé statut / تسمية الحالة
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active / نشطة';
      case 'stable':
        return 'Stable / مستقرة';
      case 'critical':
        return 'Critical / حرجة';
      case 'inactive':
        return 'Inactive / غير نشطة';
      default:
        return status;
    }
  }

  /// Status color / Couleur statut / لون الحالة
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return 'success';
      case 'stable':
        return 'info';
      case 'critical':
        return 'danger';
      case 'inactive':
        return 'secondary';
      default:
        return 'secondary';
    }
  }

  /// Has assigned doctor / A un médecin assigné / لديها طبيب متابع
  bool get hasAssignedDoctor =>
      assignedDoctorId != null && assignedDoctorId!.isNotEmpty;

  /// Has room assigned / A une chambre assignée / لديها غرفة محددة
  bool get hasRoom => roomNumber != null && roomNumber!.isNotEmpty;

  /// Number of babies / Nombre de bébés / عدد المواليد
  int get babiesCount => babies.length;

  /// Has babies / A des bébés / لديها مواليد
  bool get hasBabies => babies.isNotEmpty;

  /// Age in years / Âge en années / العمر بالسنوات
  int? get age {
    if (dateOfBirth == null) return null;
    final today = DateTime.now();
    int age = today.year - dateOfBirth!.year;
    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month && today.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Trimester / Trimestre / الثلث الحملي
  String? get trimester {
    if (pregnancyWeek == null && gestationalWeek == null) return null;
    final week = pregnancyWeek ?? gestationalWeek!;

    if (week <= 12) return 'First / Premier / الأول';
    if (week <= 26) return 'Second / Deuxième / الثاني';
    return 'Third / Troisième / الثالث';
  }

  /// Days until delivery / Jours jusqu'à l'accouchement / أيام متبقية للولادة
  int? get daysUntilDelivery {
    if (expectedDeliveryDate == null) return null;
    return expectedDeliveryDate!.difference(DateTime.now()).inDays;
  }

  /// Weeks until delivery / Semaines jusqu'à l'accouchement / أسابيع متبقية
  int? get weeksUntilDelivery {
    if (daysUntilDelivery == null) return null;
    return (daysUntilDelivery! / 7).floor();
  }

  /// Is high risk / Est à haut risque / حالة عالية الخطورة
  bool get isHighRisk {
    return status.toLowerCase() == 'critical';
  }

  /// Is in third trimester / Est au troisième trimestre / في الثلث الثالث
  bool get isInThirdTrimester {
    if (pregnancyWeek == null && gestationalWeek == null) return false;
    final week = pregnancyWeek ?? gestationalWeek!;
    return week > 26;
  }

  /// Is near delivery / Proche de l'accouchement / قريبة من الولادة
  bool get isNearDelivery {
    if (daysUntilDelivery == null) return false;
    return daysUntilDelivery! <= 14; // 2 weeks
  }

  // ════════════════════════════════════════════════════════════════
  // UTILITY METHODS / MÉTHODES UTILITAIRES / الدوال المساعدة
  // ════════════════════════════════════════════════════════════════

  /// Copy with modified fields
  /// Copier avec des champs modifiés
  /// نسخ مع تعديل حقول
  PatientModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? wilaya,
    String? address,
    String? status,
    String? bloodType,
    DateTime? dateOfBirth,
    int? pregnancyWeek,
    int? gestationalWeek,
    DateTime? lastMenstrualPeriod,
    DateTime? expectedDeliveryDate,
    String? assignedDoctorId,
    String? assignedDoctorName,
    String? assignedDoctor,
    String? roomNumber,
    String? profileImage,
    List<String>? babies,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      wilaya: wilaya ?? this.wilaya,
      address: address ?? this.address,
      status: status ?? this.status,
      bloodType: bloodType ?? this.bloodType,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      pregnancyWeek: pregnancyWeek ?? this.pregnancyWeek,
      gestationalWeek: gestationalWeek ?? this.gestationalWeek,
      lastMenstrualPeriod: lastMenstrualPeriod ?? this.lastMenstrualPeriod,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      assignedDoctorId: assignedDoctorId ?? this.assignedDoctorId,
      assignedDoctorName: assignedDoctorName ?? this.assignedDoctorName,
      assignedDoctor: assignedDoctor ?? this.assignedDoctor,
      roomNumber: roomNumber ?? this.roomNumber,
      profileImage: profileImage ?? this.profileImage,
      babies: babies ?? this.babies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON string
  /// Convertir en chaîne JSON
  /// تحويل إلى نص JSON
  @override
  String toString() {
    return 'PatientModel(uid: $uid, name: $fullName, status: $status, '
        'doctor: $assignedDoctorName, week: $pregnancyWeek, babies: $babiesCount)';
  }

  /// Equality operator
  /// Opérateur d'égalité
  /// عامل المساواة
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PatientModel && other.uid == uid;
  }

  /// Hash code
  /// Code de hachage
  /// رمز التجزئة
  @override
  int get hashCode => uid.hashCode;
}
