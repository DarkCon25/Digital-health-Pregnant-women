import 'package:cloud_firestore/cloud_firestore.dart';

// ════════════════════════════════════════════════════════════════
// HerCare - Nurse Model
// Modèle Infirmière
// ════════════════════════════════════════════════════════════════

class NurseModel {
  // ── Basic Information / Informations de base
  final String uid;
  final String firstName; // First name / Prénom
  final String lastName; // Last name / Nom
  final String email;
  final String phone; // Phone number / Téléphone

  // ── Work Information / Informations professionnelles
  final String department; // Department / Service
  final String shift; // Shift: morning/afternoon/night / Horaire
  final String status; // active / inactive / leave / Statut
  final String? specialization; // Specialization / Spécialisation
  final int? experienceYears; // Years of experience / Années d'expérience

  // ── Location & Assignment / Localisation et affectation
  final String? assignedFloor; // Assigned floor / Étage assigné
  final String? assignedWing; // Assigned wing / Aile assignée
  final List<String> assignedRooms; // Room numbers / Numéros de chambres

  // ── Profile & Media / Profil et médias
  final String? profileImage; // Profile photo / Photo de profil

  // ── Performance / Performance
  final int? patientsHandled; // Total patients handled / Total patients gérés
  final double? rating; // Rating (0-5) / Évaluation (0-5)

  // ── Availability / Disponibilité
  final bool isAvailable; // Currently available / Actuellement disponible
  final DateTime? lastShiftStart; // Last shift start / Début dernier service
  final DateTime? lastShiftEnd; // Last shift end / Fin dernier service

  // ── Emergency Contact / Contact d'urgence
  final String? emergencyContact; // Emergency phone / Téléphone urgence
  final String? emergencyRelation; // Relation / Relation

  // ── Metadata / Métadonnées
  final DateTime createdAt; // Creation date / Date de création
  final DateTime? updatedAt; // Last update / Dernière mise à jour

  NurseModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.department,
    required this.shift,
    this.status = 'active',
    this.specialization,
    this.experienceYears,
    this.assignedFloor,
    this.assignedWing,
    this.assignedRooms = const [],
    this.profileImage,
    this.patientsHandled,
    this.rating,
    this.isAvailable = true,
    this.lastShiftStart,
    this.lastShiftEnd,
    this.emergencyContact,
    this.emergencyRelation,
    required this.createdAt,
    this.updatedAt,
  });

  // ════════════════════════════════════════════════════════════════
  // FACTORY METHODS / MÉTHODES FACTORY
  // ════════════════════════════════════════════════════════════════

  /// Create from Firestore document
  /// Créer depuis un document Firestore
  factory NurseModel.fromMap(Map<String, dynamic> map) {
    return NurseModel(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      department: map['department'] ?? '',
      shift: map['shift'] ?? 'morning',
      status: map['status'] ?? 'active',
      specialization: map['specialization'],
      experienceYears: map['experienceYears'],
      assignedFloor: map['assignedFloor'],
      assignedWing: map['assignedWing'],
      assignedRooms: List<String>.from(map['assignedRooms'] ?? []),
      profileImage: map['profileImage'],
      patientsHandled: map['patientsHandled'],
      rating: map['rating']?.toDouble(),
      isAvailable: map['isAvailable'] ?? true,
      lastShiftStart: map['lastShiftStart'] != null
          ? (map['lastShiftStart'] as Timestamp).toDate()
          : null,
      lastShiftEnd: map['lastShiftEnd'] != null
          ? (map['lastShiftEnd'] as Timestamp).toDate()
          : null,
      emergencyContact: map['emergencyContact'],
      emergencyRelation: map['emergencyRelation'],
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
      'department': department,
      'shift': shift,
      'role': 'nurse',
      'status': status,
      'specialization': specialization,
      'experienceYears': experienceYears,
      'assignedFloor': assignedFloor,
      'assignedWing': assignedWing,
      'assignedRooms': assignedRooms,
      'profileImage': profileImage,
      'patientsHandled': patientsHandled,
      'rating': rating,
      'isAvailable': isAvailable,
      'lastShiftStart': lastShiftStart != null
          ? Timestamp.fromDate(lastShiftStart!)
          : null,
      'lastShiftEnd': lastShiftEnd != null
          ? Timestamp.fromDate(lastShiftEnd!)
          : null,
      'emergencyContact': emergencyContact,
      'emergencyRelation': emergencyRelation,
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
  String get fullNameWithTitle => 'Nurse $firstName $lastName';

  /// Shift label (bilingual) / Libellé horaire
  String get shiftLabel {
    switch (shift.toLowerCase()) {
      case 'morning':
        return 'Morning / Matin';
      case 'afternoon':
        return 'Afternoon / Après-midi';
      case 'night':
        return 'Night / Nuit';
      default:
        return shift;
    }
  }

  /// Shift emoji / Emoji horaire
  String get shiftEmoji {
    switch (shift.toLowerCase()) {
      case 'morning':
        return '🌅';
      case 'afternoon':
        return '🌆';
      case 'night':
        return '🌙';
      default:
        return '⏰';
    }
  }

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
        return 'Busy / Occupée';
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
      default:
        return 'secondary';
    }
  }

  /// Department label / Libellé département
  String get departmentLabel {
    final deptMap = {
      'maternity': 'Maternity / Maternité',
      'emergency': 'Emergency / Urgences',
      'pediatrics': 'Pediatrics / Pédiatrie',
      'gynecology': 'Gynecology / Gynécologie',
      'icu': 'ICU / Réanimation',
      'nicu': 'NICU / Néonatologie',
      'obstetrics': 'Obstetrics / Obstétrique',
      'surgery': 'Surgery / Chirurgie',
      'general': 'General / Général',
    };
    return deptMap[department.toLowerCase()] ?? department;
  }

  /// Is currently working / Travaille actuellement
  bool get isCurrentlyWorking {
    if (!isAvailable) return false;
    if (lastShiftStart == null) return false;
    if (lastShiftEnd != null && lastShiftEnd!.isBefore(DateTime.now())) {
      return false;
    }
    return true;
  }

  /// Is on leave / En congé
  bool get isOnLeave => status.toLowerCase() == 'leave';

  /// Is active / Active
  bool get isActive => status.toLowerCase() == 'active';

  /// Has profile image / A une photo
  bool get hasProfileImage => profileImage != null && profileImage!.isNotEmpty;

  /// Has rooms assigned / A des chambres assignées
  bool get hasRoomsAssigned => assignedRooms.isNotEmpty;

  /// Number of assigned rooms / Nombre de chambres
  int get roomsCount => assignedRooms.length;

  /// Experience level / Niveau d'expérience
  String get experienceLevel {
    if (experienceYears == null) return 'Unknown / Inconnu';
    if (experienceYears! < 2) return 'Junior / Débutante';
    if (experienceYears! < 5) return 'Intermediate / Intermédiaire';
    if (experienceYears! < 10) return 'Senior / Expérimentée';
    return 'Expert / Experte';
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

  /// Shift hours / Heures de service
  String get shiftHours {
    switch (shift.toLowerCase()) {
      case 'morning':
        return '07:00 - 15:00';
      case 'afternoon':
        return '15:00 - 23:00';
      case 'night':
        return '23:00 - 07:00';
      default:
        return 'N/A';
    }
  }

  /// Current shift duration (in hours) / Durée actuelle (en heures)
  double? get currentShiftDuration {
    if (lastShiftStart == null) return null;
    final end = lastShiftEnd ?? DateTime.now();
    return end.difference(lastShiftStart!).inMinutes / 60.0;
  }

  /// Is experienced (5+ years) / Expérimentée (5+ ans)
  bool get isExperienced {
    return experienceYears != null && experienceYears! >= 5;
  }

  /// Is highly rated (4+ stars) / Bien notée (4+ étoiles)
  bool get isHighlyRated {
    return rating != null && rating! >= 4.0;
  }

  /// Has emergency contact / A un contact d'urgence
  bool get hasEmergencyContact {
    return emergencyContact != null && emergencyContact!.isNotEmpty;
  }

  /// Location description / Description localisation
  String get locationDescription {
    final parts = <String>[];
    if (assignedFloor != null) parts.add('Floor $assignedFloor / Étage $assignedFloor');
    if (assignedWing != null) parts.add('Wing $assignedWing / Aile $assignedWing');
    if (parts.isEmpty) return 'Not assigned / Non assignée';
    return parts.join(', ');
  }

  /// Performance summary / Résumé performance
  String get performanceSummary {
    final parts = <String>[];
    if (patientsHandled != null) {
      parts.add('$patientsHandled patients');
    }
    if (rating != null) {
      parts.add('Rating: ${rating!.toStringAsFixed(1)}★ / Note: ${rating!.toStringAsFixed(1)}★');
    }
    if (parts.isEmpty) return 'No data / Pas de données';
    return parts.join(' • ');
  }

  // ════════════════════════════════════════════════════════════════
  // UTILITY METHODS / MÉTHODES UTILITAIRES
  // ════════════════════════════════════════════════════════════════

  /// Copy with modified fields
  /// Copier avec des champs modifiés
  NurseModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? department,
    String? shift,
    String? status,
    String? specialization,
    int? experienceYears,
    String? assignedFloor,
    String? assignedWing,
    List<String>? assignedRooms,
    String? profileImage,
    int? patientsHandled,
    double? rating,
    bool? isAvailable,
    DateTime? lastShiftStart,
    DateTime? lastShiftEnd,
    String? emergencyContact,
    String? emergencyRelation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NurseModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      shift: shift ?? this.shift,
      status: status ?? this.status,
      specialization: specialization ?? this.specialization,
      experienceYears: experienceYears ?? this.experienceYears,
      assignedFloor: assignedFloor ?? this.assignedFloor,
      assignedWing: assignedWing ?? this.assignedWing,
      assignedRooms: assignedRooms ?? this.assignedRooms,
      profileImage: profileImage ?? this.profileImage,
      patientsHandled: patientsHandled ?? this.patientsHandled,
      rating: rating ?? this.rating,
      isAvailable: isAvailable ?? this.isAvailable,
      lastShiftStart: lastShiftStart ?? this.lastShiftStart,
      lastShiftEnd: lastShiftEnd ?? this.lastShiftEnd,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyRelation: emergencyRelation ?? this.emergencyRelation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON string
  /// Convertir en chaîne JSON
  @override
  String toString() {
    return 'NurseModel(uid: $uid, name: $fullName, department: $department, '
        'shift: $shift, status: $status, available: $isAvailable)';
  }

  /// Equality operator
  /// Opérateur d'égalité
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NurseModel && other.uid == uid;
  }

  /// Hash code
  /// Code de hachage
  @override
  int get hashCode => uid.hashCode;

  // ════════════════════════════════════════════════════════════════
  // VALIDATION METHODS / MÉTHODES DE VALIDATION
  // ════════════════════════════════════════════════════════════════

  /// Validate nurse data / Valider les données
  static String? validate(NurseModel nurse) {
    if (nurse.firstName.isEmpty) {
      return 'First name is required / Prénom requis';
    }
    if (nurse.lastName.isEmpty) {
      return 'Last name is required / Nom requis';
    }
    if (nurse.email.isEmpty || !nurse.email.contains('@')) {
      return 'Valid email is required / Email valide requis';
    }
    if (nurse.phone.isEmpty) {
      return 'Phone number is required / Téléphone requis';
    }
    if (nurse.department.isEmpty) {
      return 'Department is required / Service requis';
    }
    if (!['morning', 'afternoon', 'night'].contains(nurse.shift.toLowerCase())) {
      return 'Invalid shift / Horaire invalide';
    }
    return null; // Valid / Valide
  }

  /// Is valid / Est valide
  bool get isValid => validate(this) == null;
}

// ════════════════════════════════════════════════════════════════
// EXTENSION METHODS / MÉTHODES D'EXTENSION
// ════════════════════════════════════════════════════════════════

extension NurseModelExtensions on NurseModel {
  /// Format for display in lists
  /// Format pour affichage en listes
  String get displayTitle => '$fullName ($departmentLabel)';

  /// Format for display in cards
  /// Format pour affichage en cartes
  String get displaySubtitle => '$shiftLabel • $statusLabel';

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
      0xFFEC4899, // Pink / Rose
      0xFFF59E0B, // Orange
      0xFF7C3AED, // Purple / Violet
    ];
    return colors[hash.abs() % colors.length];
  }
}
