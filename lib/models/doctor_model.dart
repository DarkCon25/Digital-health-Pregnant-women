import 'package:cloud_firestore/cloud_firestore.dart';

// ════════════════════════════════════════════════════════════════
// HerCare - Doctor Model
// Modèle Médecin
// ════════════════════════════════════════════════════════════════

class DoctorModel {
  // ── Basic Information / Informations de base
  final String uid;
  final String firstName; // First name / Prénom
  final String lastName; // Last name / Nom
  final String email;
  final String phone; // Phone number / Téléphone

  // ── Professional Information / Informations professionnelles
  final String specialty; // Medical specialty / Spécialité médicale
  final String? subSpecialty; // Sub-specialty / Sous-spécialité
  final String status; // active / inactive / leave / Statut
  final int? experienceYears; // Years of experience / Années d'expérience
  final String? licenseNumber; // Medical license number / Numéro de licence
  final DateTime?
      licenseExpiry; // License expiry date / Date expiration licence

  // ── Qualifications / Qualifications
  final List<String> degrees; // Medical degrees / Diplômes médicaux
  final List<String> certifications; // Certifications / Certifications
  final String? medicalSchool; // Medical school / École de médecine
  final int? graduationYear; // Graduation year / Année de diplomation

  // ── Work Schedule / Horaire de travail
  final List<String> workingDays; // Working days / Jours de travail
  final String? workingHours; // Working hours / Heures de travail
  final bool isAvailable; // Currently available / Actuellement disponible

  // ── Patients & Performance / Patients et performance
  final int
      patients; // Number of assigned patients / Nombre de patientes assignées
  final int? maxPatients; // Maximum patients capacity / Capacité maximale
  final double? rating; // Doctor rating (0-5) / Évaluation (0-5)
  final int? totalConsultations; // Total consultations / Total consultations
  final int?
      successfulDeliveries; // Successful deliveries / Accouchements réussis

  // ── Contact & Location / Contact et localisation
  final String? officeNumber; // Office/Room number / Numéro de bureau
  final String? extension; // Phone extension / Extension téléphonique
  final String? department; // Department / Service

  // ── Profile & Media / Profil et médias
  final String? profileImage; // Profile photo / Photo de profil
  final String? signature; // Digital signature / Signature numérique
  final String? bio; // Biography / Biographie

  // ── Emergency & Availability / Urgence et disponibilité
  final String? emergencyContact; // Emergency contact / Contact d'urgence
  final String? emergencyRelation; // Relation / Relation
  final bool onCallToday; // On call today / De garde aujourd'hui
  final DateTime? lastConsultation; // Last consultation / Dernière consultation

  // ── Languages / Langues
  final List<String> languages; // Spoken languages / Langues parlées

  // ── Metadata / Métadonnées
  final DateTime createdAt; // Creation date / Date de création
  final DateTime? updatedAt; // Last update / Dernière mise à jour

  DoctorModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.specialty,
    this.subSpecialty,
    this.status = 'active',
    this.experienceYears,
    this.licenseNumber,
    this.licenseExpiry,
    this.degrees = const [],
    this.certifications = const [],
    this.medicalSchool,
    this.graduationYear,
    this.workingDays = const [],
    this.workingHours,
    this.isAvailable = true,
    this.patients = 0,
    this.maxPatients,
    this.rating,
    this.totalConsultations,
    this.successfulDeliveries,
    this.officeNumber,
    this.extension,
    this.department,
    this.profileImage,
    this.signature,
    this.bio,
    this.emergencyContact,
    this.emergencyRelation,
    this.onCallToday = false,
    this.lastConsultation,
    this.languages = const [],
    required this.createdAt,
    this.updatedAt,
  });

  // ════════════════════════════════════════════════════════════════
  // FACTORY METHODS / MÉTHODES FACTORY
  // ════════════════════════════════════════════════════════════════

  /// Create from Firestore document
  /// Créer depuis un document Firestore
  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      specialty: map['specialty'] ?? '',
      subSpecialty: map['subSpecialty'],
      status: map['status'] ?? 'active',
      experienceYears: map['experienceYears'],
      licenseNumber: map['licenseNumber'],
      licenseExpiry: map['licenseExpiry'] != null
          ? (map['licenseExpiry'] as Timestamp).toDate()
          : null,
      degrees: List<String>.from(map['degrees'] ?? []),
      certifications: List<String>.from(map['certifications'] ?? []),
      medicalSchool: map['medicalSchool'],
      graduationYear: map['graduationYear'],
      workingDays: List<String>.from(map['workingDays'] ?? []),
      workingHours: map['workingHours'],
      isAvailable: map['isAvailable'] ?? true,
      patients: map['patients'] ?? 0,
      maxPatients: map['maxPatients'],
      rating: map['rating']?.toDouble(),
      totalConsultations: map['totalConsultations'],
      successfulDeliveries: map['successfulDeliveries'],
      officeNumber: map['officeNumber'],
      extension: map['extension'],
      department: map['department'],
      profileImage: map['profileImage'],
      signature: map['signature'],
      bio: map['bio'],
      emergencyContact: map['emergencyContact'],
      emergencyRelation: map['emergencyRelation'],
      onCallToday: map['onCallToday'] ?? false,
      lastConsultation: map['lastConsultation'] != null
          ? (map['lastConsultation'] as Timestamp).toDate()
          : null,
      languages: List<String>.from(map['languages'] ?? []),
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
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'specialty': specialty,
      'subSpecialty': subSpecialty,
      'role': 'doctor',
      'status': status,
      'experienceYears': experienceYears,
      'licenseNumber': licenseNumber,
      'licenseExpiry':
          licenseExpiry != null ? Timestamp.fromDate(licenseExpiry!) : null,
      'degrees': degrees,
      'certifications': certifications,
      'medicalSchool': medicalSchool,
      'graduationYear': graduationYear,
      'workingDays': workingDays,
      'workingHours': workingHours,
      'isAvailable': isAvailable,
      'patients': patients,
      'maxPatients': maxPatients,
      'rating': rating,
      'totalConsultations': totalConsultations,
      'successfulDeliveries': successfulDeliveries,
      'officeNumber': officeNumber,
      'extension': extension,
      'department': department,
      'profileImage': profileImage,
      'signature': signature,
      'bio': bio,
      'emergencyContact': emergencyContact,
      'emergencyRelation': emergencyRelation,
      'onCallToday': onCallToday,
      'lastConsultation': lastConsultation != null
          ? Timestamp.fromDate(lastConsultation!)
          : null,
      'languages': languages,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // ════════════════════════════════════════════════════════════════
  // GETTERS / ACCESSEURS
  // ════════════════════════════════════════════════════════════════

  /// Full name / Nom complet
  String get fullName => '$firstName $lastName';

  /// Full name with title / Nom avec titre
  String get fullNameWithTitle => 'Dr. $firstName $lastName';

  /// Status label / Libellé statut
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'leave':
        return 'On Leave / En congé';
      case 'busy':
        return 'Busy / Occupé(e)';
      case 'retired':
        return 'Retired / Retraité(e)';
      default:
        return status;
    }
  }

  /// Status color code / Code couleur statut
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return 'success';
      case 'inactive':
        return 'secondary';
      case 'leave':
        return 'warning';
      case 'busy':
        return 'info';
      case 'retired':
        return 'secondary';
      default:
        return 'secondary';
    }
  }

  /// Specialty label / Libellé spécialité
  String get specialtyLabel {
    final specialtyMap = {
      'obstetrics': 'Obstetrics / Obstétrique',
      'gynecology': 'Gynecology / Gynécologie',
      'obgyn': 'OB/GYN / Obstétrique-Gynécologie',
      'maternal-fetal': 'Maternal-Fetal Medicine / Médecine materno-fœtale',
      'neonatology': 'Neonatology / Néonatologie',
      'pediatrics': 'Pediatrics / Pédiatrie',
      'anesthesiology': 'Anesthesiology / Anesthésiologie',
      'general': 'General Practice / Médecine générale',
    };
    return specialtyMap[specialty.toLowerCase()] ?? specialty;
  }

  /// Is active / Est actif
  bool get isActive => status.toLowerCase() == 'active';

  /// Is on leave / En congé
  bool get isOnLeave => status.toLowerCase() == 'leave';

  /// Has profile image / A une photo
  bool get hasProfileImage => profileImage != null && profileImage!.isNotEmpty;

  /// Has patients / A des patientes
  bool get hasPatients => patients > 0;

  /// Is at capacity / À capacité maximale
  bool get isAtCapacity {
    if (maxPatients == null) return false;
    return patients >= maxPatients!;
  }

  /// Can accept new patients / Peut accepter nouvelles patientes
  bool get canAcceptNewPatients {
    if (!isActive) return false;
    if (!isAvailable) return false;
    if (isAtCapacity) return false;
    return true;
  }

  /// Experience level / Niveau d'expérience
  String get experienceLevel {
    if (experienceYears == null) return 'Unknown / Inconnu';
    if (experienceYears! < 3) return 'Junior / Débutant(e)';
    if (experienceYears! < 7) return 'Mid-level / Intermédiaire';
    if (experienceYears! < 15) return 'Senior / Expérimenté(e)';
    return 'Expert / Expert(e)';
  }

  /// Rating stars / Étoiles
  String get ratingStars {
    if (rating == null) return '☆☆☆☆☆';
    final fullStars = rating!.floor();
    final hasHalf = (rating! - fullStars) >= 0.5;
    String stars = '★' * fullStars;
    if (hasHalf) stars += '½';
    stars += '☆' * (5 - fullStars - (hasHalf ? 1 : 0));
    return stars;
  }

  /// Is highly rated (4+ stars) / Bien noté (4+ étoiles)
  bool get isHighlyRated {
    return rating != null && rating! >= 4.0;
  }

  /// Is experienced (7+ years) / Expérimenté (7+ ans)
  bool get isExperienced {
    return experienceYears != null && experienceYears! >= 7;
  }

  /// Has valid license / A une licence valide
  bool get hasValidLicense {
    if (licenseExpiry == null) return false;
    return licenseExpiry!.isAfter(DateTime.now());
  }

  /// License expires soon (within 90 days) / Licence expire bientôt
  bool get licenseExpiresSoon {
    if (licenseExpiry == null) return false;
    final daysUntilExpiry = licenseExpiry!.difference(DateTime.now()).inDays;
    return daysUntilExpiry > 0 && daysUntilExpiry <= 90;
  }

  /// Days until license expiry / Jours avant expiration licence
  int? get daysUntilLicenseExpiry {
    if (licenseExpiry == null) return null;
    return licenseExpiry!.difference(DateTime.now()).inDays;
  }

  /// Workload percentage / Pourcentage de charge de travail
  double? get workloadPercentage {
    if (maxPatients == null || maxPatients == 0) return null;
    return (patients / maxPatients!) * 100;
  }

  /// Workload status / Statut charge de travail
  String get workloadStatus {
    final percentage = workloadPercentage;
    if (percentage == null) return 'Unknown / Inconnu';
    if (percentage < 50) return 'Light / Légère';
    if (percentage < 75) return 'Moderate / Modérée';
    if (percentage < 90) return 'Heavy / Élevée';
    return 'Full / Complète';
  }

  /// Working days formatted / Jours de travail formatés
  String get workingDaysFormatted {
    if (workingDays.isEmpty) return 'Not specified / Non spécifié';
    final dayMap = {
      'monday': 'Mon/Lun',
      'tuesday': 'Tue/Mar',
      'wednesday': 'Wed/Mer',
      'thursday': 'Thu/Jeu',
      'friday': 'Fri/Ven',
      'saturday': 'Sat/Sam',
      'sunday': 'Sun/Dim',
    };
    return workingDays
        .map((day) => dayMap[day.toLowerCase()] ?? day)
        .join(', ');
  }

  /// Languages formatted / Langues formatées
  String get languagesFormatted {
    if (languages.isEmpty) return 'Not specified / Non spécifié';
    final langMap = {
      'arabic': 'Arabic / Arabe',
      'french': 'French / Français',
      'english': 'English / Anglais',
      'spanish': 'Spanish / Espagnol',
      'german': 'German / Allemand',
    };
    return languages
        .map((lang) => langMap[lang.toLowerCase()] ?? lang)
        .join(', ');
  }

  /// Success rate / Taux de réussite
  double? get successRate {
    if (totalConsultations == null ||
        totalConsultations == 0 ||
        successfulDeliveries == null) {
      return null;
    }
    return (successfulDeliveries! / totalConsultations!) * 100;
  }

  /// Success rate formatted / Taux de réussite formaté
  String get successRateFormatted {
    final rate = successRate;
    if (rate == null) return 'N/A';
    return '${rate.toStringAsFixed(1)}%';
  }

  /// Contact information / Informations de contact
  String get contactInfo {
    final parts = <String>[];
    parts.add('📧 $email');
    parts.add('📞 $phone');
    if (extension != null) parts.add('Ext: $extension');
    if (officeNumber != null) {
      parts.add('🚪 Office $officeNumber / Bureau $officeNumber');
    }
    return parts.join(' • ');
  }

  /// Professional summary / Résumé professionnel
  String get professionalSummary {
    final parts = <String>[];
    parts.add(specialtyLabel);
    if (experienceYears != null) {
      parts.add('$experienceYears years / ans');
    }
    if (rating != null) {
      parts.add('${rating!.toStringAsFixed(1)}★');
    }
    parts.add('$patients patients');
    return parts.join(' • ');
  }

  /// Credentials / Titres
  String get credentials {
    final creds = <String>[];
    creds.addAll(degrees);
    creds.addAll(certifications);
    if (creds.isEmpty) return 'N/A';
    return creds.join(', ');
  }

  /// Has emergency contact / A un contact d'urgence
  bool get hasEmergencyContact {
    return emergencyContact != null && emergencyContact!.isNotEmpty;
  }

  /// Has signature / A une signature
  bool get hasSignature {
    return signature != null && signature!.isNotEmpty;
  }

  /// Has bio / A une biographie
  bool get hasBio {
    return bio != null && bio!.isNotEmpty;
  }

  /// Years since graduation / Années depuis diplomation
  int? get yearsSinceGraduation {
    if (graduationYear == null) return null;
    return DateTime.now().year - graduationYear!;
  }

  /// Is available today / Disponible aujourd'hui
  bool get isAvailableToday {
    if (!isAvailable) return false;
    if (workingDays.isEmpty) return true; // Assume available if not specified
    final today = _getCurrentWeekday();
    return workingDays.contains(today.toLowerCase());
  }

  String _getCurrentWeekday() {
    const weekdays = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    return weekdays[DateTime.now().weekday - 1];
  }

  // ════════════════════════════════════════════════════════════════
  // UTILITY METHODS / MÉTHODES UTILITAIRES
  // ════════════════════════════════════════════════════════════════

  /// Copy with modified fields
  /// Copier avec des champs modifiés
  DoctorModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? specialty,
    String? subSpecialty,
    String? status,
    int? experienceYears,
    String? licenseNumber,
    DateTime? licenseExpiry,
    List<String>? degrees,
    List<String>? certifications,
    String? medicalSchool,
    int? graduationYear,
    List<String>? workingDays,
    String? workingHours,
    bool? isAvailable,
    int? patients,
    int? maxPatients,
    double? rating,
    int? totalConsultations,
    int? successfulDeliveries,
    String? officeNumber,
    String? extension,
    String? department,
    String? profileImage,
    String? signature,
    String? bio,
    String? emergencyContact,
    String? emergencyRelation,
    bool? onCallToday,
    DateTime? lastConsultation,
    List<String>? languages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialty: specialty ?? this.specialty,
      subSpecialty: subSpecialty ?? this.subSpecialty,
      status: status ?? this.status,
      experienceYears: experienceYears ?? this.experienceYears,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      degrees: degrees ?? this.degrees,
      certifications: certifications ?? this.certifications,
      medicalSchool: medicalSchool ?? this.medicalSchool,
      graduationYear: graduationYear ?? this.graduationYear,
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
      isAvailable: isAvailable ?? this.isAvailable,
      patients: patients ?? this.patients,
      maxPatients: maxPatients ?? this.maxPatients,
      rating: rating ?? this.rating,
      totalConsultations: totalConsultations ?? this.totalConsultations,
      successfulDeliveries: successfulDeliveries ?? this.successfulDeliveries,
      officeNumber: officeNumber ?? this.officeNumber,
      extension: extension ?? this.extension,
      department: department ?? this.department,
      profileImage: profileImage ?? this.profileImage,
      signature: signature ?? this.signature,
      bio: bio ?? this.bio,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyRelation: emergencyRelation ?? this.emergencyRelation,
      onCallToday: onCallToday ?? this.onCallToday,
      lastConsultation: lastConsultation ?? this.lastConsultation,
      languages: languages ?? this.languages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON string
  /// Convertir en chaîne JSON
  @override
  String toString() {
    return 'DoctorModel(uid: $uid, name: $fullName, specialty: $specialty, '
        'patients: $patients, rating: $rating, status: $status)';
  }

  /// Equality operator
  /// Opérateur d'égalité
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoctorModel && other.uid == uid;
  }

  /// Hash code
  /// Code de hachage
  @override
  int get hashCode => uid.hashCode;

  // ════════════════════════════════════════════════════════════════
  // VALIDATION METHODS / MÉTHODES DE VALIDATION
  // ════════════════════════════════════════════════════════════════

  /// Validate doctor data / Valider les données
  static String? validate(DoctorModel doctor) {
    if (doctor.firstName.isEmpty) {
      return 'First name is required / Prénom requis';
    }
    if (doctor.lastName.isEmpty) {
      return 'Last name is required / Nom requis';
    }
    if (doctor.email.isEmpty || !doctor.email.contains('@')) {
      return 'Valid email is required / Email valide requis';
    }
    if (doctor.phone.isEmpty) {
      return 'Phone number is required / Téléphone requis';
    }
    if (doctor.specialty.isEmpty) {
      return 'Specialty is required / Spécialité requise';
    }
    if (doctor.licenseExpiry != null &&
        doctor.licenseExpiry!.isBefore(DateTime.now())) {
      return 'Medical license has expired / Licence médicale expirée';
    }
    return null; // Valid / Valide
  }

  /// Is valid / Est valide
  bool get isValid => validate(this) == null;
}

// ════════════════════════════════════════════════════════════════
// EXTENSION METHODS / MÉTHODES D'EXTENSION
// ════════════════════════════════════════════════════════════════

extension DoctorModelExtensions on DoctorModel {
  /// Format for display in lists
  /// Format pour affichage en listes
  String get displayTitle => '$fullNameWithTitle ($specialtyLabel)';

  /// Format for display in cards
  /// Format pour affichage en cartes
  String get displaySubtitle => professionalSummary;

  /// Initials for avatar / Initiales pour avatar
  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  /// Color for avatar background / Couleur fond avatar
  int get avatarColorCode {
    final hash = fullName.hashCode;
    final colors = [
      0xFF2563EB, // Blue / Bleu
      0xFF10B981, // Green / Vert
      0xFF7C3AED, // Purple / Violet
      0xFF0EA5E9, // Sky / Ciel
      0xFF8B5CF6, // Violet
    ];
    return colors[hash.abs() % colors.length];
  }

  /// Availability badge text / Texte badge disponibilité
  String get availabilityBadge {
    if (!isAvailable) return 'Unavailable / Indisponible';
    if (onCallToday) return 'On Call / De garde';
    if (isAtCapacity) return 'Full / Complet';
    return 'Available / Disponible';
  }

  /// Availability badge color / Couleur badge disponibilité
  String get availabilityBadgeColor {
    if (!isAvailable) return 'secondary';
    if (onCallToday) return 'warning';
    if (isAtCapacity) return 'danger';
    return 'success';
  }
}
