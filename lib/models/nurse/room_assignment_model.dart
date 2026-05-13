/// Optional link between a room and a patient (denormalized from `rooms`).
class RoomAssignmentModel {
  RoomAssignmentModel({
    required this.roomId,
    required this.roomNumber,
    required this.status,
    this.patientId,
    this.patientName,
    this.type,
  });

  final String roomId;
  final String roomNumber;
  final String status;
  final String? patientId;
  final String? patientName;
  final String? type;

  factory RoomAssignmentModel.fromRoomDoc(
    String id,
    Map<String, dynamic> m,
  ) {
    return RoomAssignmentModel(
      roomId: id,
      roomNumber: m['number']?.toString() ?? id,
      status: m['status'] as String? ?? 'available',
      patientId: m['patientId'] as String?,
      patientName: m['patientName'] as String?,
      type: m['type'] as String?,
    );
  }
}
