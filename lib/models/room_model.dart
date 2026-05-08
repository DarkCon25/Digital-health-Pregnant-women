// ============================================
// HerCare - Room Model
// Modèle Chambre
// ============================================

class RoomModel {
  final String id; // Firestore document ID
  final String number; // Room number / Numéro de chambre
  final String type; // private / general / icu / maternity
  final int floor; // Floor / Étage
  final int capacity; // Capacity / Capacité
  final String status; // available / occupied / maintenance
  final String? patientName; // Assigned patient / Patient assigné
  final DateTime? createdAt;

  RoomModel({
    required this.id,
    required this.number,
    required this.type,
    required this.floor,
    required this.capacity,
    required this.status,
    this.patientName,
    this.createdAt,
  });

  // From Firestore / Depuis Firestore
  factory RoomModel.fromMap(String id, Map<String, dynamic> map) {
    return RoomModel(
      id: id,
      number: map['number'] ?? '',
      type: map['type'] ?? 'general',
      floor: map['floor'] ?? 1,
      capacity: map['capacity'] ?? 1,
      status: map['status'] ?? 'available',
      patientName: map['patientName'],
      createdAt: map['createdAt']?.toDate(),
    );
  }

  // To Firestore / Vers Firestore
  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'type': type,
      'floor': floor,
      'capacity': capacity,
      'status': status,
      'patientName': patientName,
    };
  }

  // Type label / Libellé type
  String get typeLabel {
    switch (type) {
      case 'private':
        return 'Private / Privée';
      case 'general':
        return 'General / Générale';
      case 'icu':
        return 'ICU / Soins intensifs';
      case 'maternity':
        return 'Maternity / Maternité';
      default:
        return type;
    }
  }

  // Status label / Libellé statut
  String get statusLabel {
    switch (status) {
      case 'available':
        return 'Available / Disponible';
      case 'occupied':
        return 'Occupied / Occupée';
      case 'maintenance':
        return 'Maintenance';
      default:
        return status;
    }
  }

  // Is available / Est disponible
  bool get isAvailable => status == 'available';
}
