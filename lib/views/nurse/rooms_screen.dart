import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/nurse_colors.dart';
import '../../core/nurse_strings.dart';
import '../../models/room_model.dart';
import '../../services/nurse_service.dart';
import '../../widgets/nurse/nurse_screen_chrome.dart';
import '../../widgets/nurse/room_badge.dart';

/// Nurse Rooms Screen - View rooms and assign patients to rooms
/// شاشة غرف الممرضة - عرض الغرف وAssign / Assigner المرضى للغرف
class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  void _showAssignPatientDialog(BuildContext context, RoomModel room) {
    final service = context.read<NurseService>();
    String? selectedPatientId;
    String? selectedPatientName;

    showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setS) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bed_outlined, color: NurseColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Assign patient to room ${room.number}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: NurseColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dCtx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Select a patient to assign to this room / Selectionnez une patiente pour cette chambre',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: NurseColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'patient')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final patients = snapshot.data!.docs;
                    if (patients.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: NurseColors.tint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'No patients available for assignment / Aucune patiente disponible pour attribution',
                            style: GoogleFonts.inter(
                              color: NurseColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Patient / Patiente',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: NurseColors.pageBg,
                      ),
                      hint: Text(
                        'Select patient / Selectionner la patiente',
                        style: GoogleFonts.inter(
                          color: NurseColors.textSecondary,
                        ),
                      ),
                      items: patients.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name =
                            '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
                                .trim();
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setS(() {
                          selectedPatientId = value;
                          // Find patient name
                          final patient = patients.firstWhere(
                            (p) => p.id == value,
                            orElse: () => patients.first,
                          );
                          final data = patient.data() as Map<String, dynamic>;
                          selectedPatientName =
                              '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dCtx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cancel / Annuler',
                          style: GoogleFonts.inter(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: selectedPatientId == null
                            ? null
                            : () async {
                                try {
                                  // Assign patient to room
                                  await service.assignRoomToPatient(
                                    patientId: selectedPatientId!,
                                    roomNumber: room.number,
                                  );
                                  // Update room status in Firestore
                                  await FirebaseFirestore.instance
                                      .collection('rooms')
                                      .doc(room.id)
                                      .update({
                                    'status': 'occupied',
                                    'patientName': selectedPatientName,
                                    'updatedAt': FieldValue.serverTimestamp(),
                                  });
                                  if (dCtx.mounted) {
                                    Navigator.pop(dCtx);
                                  }
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Patient assigned successfully / Patiente assignee avec succes'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error / Erreur: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NurseColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Assign / Assigner',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReleaseRoomDialog(BuildContext context, RoomModel room) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Release room ${room.number}',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: const Text('Are you sure you want to release this room? / Etes-vous sur de liberer cette chambre ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel / Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Update room status to available
                await FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(room.id)
                    .update({
                  'status': 'available',
                  'patientName': null,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                if (dCtx.mounted) {
                  Navigator.pop(dCtx);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Room released successfully / Chambre liberee avec succes'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error / Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NurseColors.critical,
            ),
            child: const Text('Confirm / Confirmer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<NurseService>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const NursePageHeader(
            title: NurseStrings.pageRooms,
            subtitle: NurseStrings.roomAvailable,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<RoomModel>>(
              stream: service.watchRooms(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final rooms = snap.data!;
                if (rooms.isEmpty) {
                  return Center(
                    child: Text(
                      NurseStrings.noRooms,
                      style: GoogleFonts.inter(
                        color: NurseColors.textSecondary,
                      ),
                    ),
                  );
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: rooms.length,
                  itemBuilder: (context, i) {
                    final r = rooms[i];
                    final isAvailable = r.status == 'available';
                    return NurseSurfaceCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bed_outlined),
                              const SizedBox(width: 8),
                              Text(
                                r.number,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                              const Spacer(),
                              RoomBadge(status: r.status),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            r.typeLabel,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: NurseColors.textSecondary,
                            ),
                          ),
                          if (r.patientName != null &&
                              r.patientName!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                r.patientName!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              if (isAvailable)
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _showAssignPatientDialog(context, r),
                                    icon: const Icon(Icons.person_add,
                                        size: 16),
                                    label: const Text('Assign patient / Assigner une patiente'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: NurseColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              if (!isAvailable)
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _showReleaseRoomDialog(context, r),
                                    icon: const Icon(Icons.logout, size: 16),
                                    label: const Text('Release / Liberer'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: NurseColors.critical,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
