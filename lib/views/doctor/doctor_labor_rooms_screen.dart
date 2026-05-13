import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/doctor_colors.dart';
import '../../core/app_strings.dart';
import '../../models/room_model.dart';
import '../../services/doctor_service.dart';
import '../../widgets/doctor/doctor_screen_chrome.dart';

/// Labor / maternity rooms — Firestore `rooms` collection (dynamic).
class DoctorLaborRoomsScreen extends StatelessWidget {
  const DoctorLaborRoomsScreen({super.key});

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
              DoctorPageHeader(
                title: DoctorStrings.laborRoomsTitle,
                subtitle: DoctorStrings.laborRoomsSubtitle,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: rooms.take(12).map((r) {
                  final occ = r.status.toLowerCase() == 'occupied';
                  return Container(
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
                      ],
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
            ],
          );
        },
      ),
    );
  }
}
