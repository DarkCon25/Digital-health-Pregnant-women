import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/doctor_colors.dart';
import '../../core/app_strings.dart';
import '../../models/patient_model.dart';
import '../../models/room_model.dart';
import '../../services/doctor_service.dart';
import '../../widgets/doctor/doctor_screen_chrome.dart';

/// Labor / maternity rooms — Firestore `rooms` collection (dynamic).
/// الطبيب يختار غرفة للمريضة
class DoctorLaborRoomsScreen extends StatefulWidget {
  const DoctorLaborRoomsScreen({super.key});

  @override
  State<DoctorLaborRoomsScreen> createState() => _DoctorLaborRoomsScreenState();
}

class _DoctorLaborRoomsScreenState extends State<DoctorLaborRoomsScreen> {
  @override
  Widget build(BuildContext context) {
    final service = context.read<DoctorService>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: StreamBuilder<List<RoomModel>>(
        stream: service.watchRooms(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snap.data!;
          final labor = all.where((r) {
            final t = r.type.toLowerCase();
            return t == 'maternity' ||
                t.contains('labor') ||
                t.contains('delivery');
          }).toList();
          final rooms = labor.isNotEmpty ? labor : all;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DoctorPageHeader(
                title: DoctorStrings.laborRoomsTitle,
                subtitle: DoctorStrings.laborRoomsSubtitle,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: rooms.take(12).map((r) {
                  final occ = r.status.toLowerCase() == 'occupied';
                  return GestureDetector(
                    onTap: !occ
                        ? () => _showAssignPatientDialog(context, service, r)
                        : null,
                    child: Container(
                      width: 160,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: occ
                              ? DoctorColors.critical.withValues(alpha: 0.5)
                              : DoctorColors.success.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DoctorStrings.roomNumberLabel(r.number),
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            occ
                                ? DoctorStrings.roomOccupied
                                : DoctorStrings.roomAvailable,
                            style: GoogleFonts.inter(
                              color: occ
                                  ? DoctorColors.critical
                                  : DoctorColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (occ && (r.patientName?.isNotEmpty ?? false))
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                r.patientName!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(fontSize: 12),
                              ),
                            ),
                          if (!occ)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Tap to select a patient / Appuyez pour selectionner une patiente',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: DoctorColors.success,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                DoctorStrings.occupiedRoomsList,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: DoctorSurfaceCard(
                  padding: EdgeInsets.zero,
                  child: SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text(DoctorStrings.roomLabel)),
                          DataColumn(label: Text(DoctorStrings.colType)),
                          DataColumn(label: Text(DoctorStrings.colStatus)),
                          DataColumn(label: Text(DoctorStrings.colPatient)),
                        ],
                        rows: rooms
                            .where((r) => r.status.toLowerCase() == 'occupied')
                            .map(
                              (r) => DataRow(
                                cells: [
                                  DataCell(Text(r.number)),
                                  DataCell(Text(r.type)),
                                  DataCell(Text(r.status)),
                                  DataCell(Text(r.patientName ?? '—')),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Show dialog to assign patient to room
  void _showAssignPatientDialog(
    BuildContext context,
    DoctorService service,
    RoomModel room,
  ) {
    String? selectedPatientId;
    String? selectedPatientName;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select patient / Selectionner la patiente to room ${room.number}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: DoctorColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                StreamBuilder<List<PatientModel>>(
                  stream: service.watchPatientsForDoctor(
                    context.read<DoctorService>().currentUid ?? '',
                  ),
                  builder: (dCtx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final patients = snap.data ?? [];
                    if (patients.isEmpty) {
                      return Center(
                        child: Text(
                          'No patients assigned to you / Aucune patiente ne vous est assignee',
                          style: GoogleFonts.inter(
                            color: DoctorColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    // تم تغيير p.id إلى p.uid لتجنب الخطأ
                    if (selectedPatientId != null &&
                        !patients.any((p) => p.uid == selectedPatientId)) {
                      selectedPatientId = null;
                      selectedPatientName = null;
                    }

                    return DropdownButtonFormField<String>(
                      // استخدمنا initialValue لتجنب التحذير الأزرق الذي ظهر لديك
                      initialValue: selectedPatientId,
                      onChanged: isSaving
                          ? null
                          : (v) => setDialogState(() {
                                selectedPatientId = v;
                                selectedPatientName = null;
                                for (final p in patients) {
                                  if (p.uid == v) {
                                    selectedPatientName = p.fullName;
                                    break;
                                  }
                                }
                              }),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: DoctorColors.cardBorder,
                          ),
                        ),
                      ),
                      items: patients
                          .map(
                            (p) => DropdownMenuItem(
                              // تم تغيير p.id إلى p.uid
                              value: p.uid,
                              child: Text(
                                p.fullName,
                                style: GoogleFonts.inter(),
                              ),
                            ),
                          )
                          .toList(),
                      hint: Text(
                        'Select patient / Selectionner la patiente',
                        style: GoogleFonts.inter(
                          color: DoctorColors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSaving ? null : () => Navigator.pop(dCtx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Cancel / Annuler', style: GoogleFonts.poppins()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (selectedPatientId == null || isSaving)
                            ? null
                            : () async {
                                setDialogState(() => isSaving = true);
                                try {
                                  await service.updatePatientRoom(
                                    patientId: selectedPatientId!,
                                    roomNumber: room.number,
                                  );

                                  if (dCtx.mounted) Navigator.pop(dCtx);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Assigned $selectedPatientName to room ${room.number}',
                                        ),
                                        backgroundColor: DoctorColors.success,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error / Erreur: $e'),
                                        backgroundColor: DoctorColors.critical,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (dCtx.mounted) {
                                    setDialogState(() => isSaving = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DoctorColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save / Enregistrer',
                                style: GoogleFonts.poppins(
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
}
