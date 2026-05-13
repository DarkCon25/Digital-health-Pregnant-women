import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/nurse_colors.dart';
import '../../core/nurse_strings.dart';
import '../../models/room_model.dart';
import '../../services/nurse_service.dart';
import '../../widgets/nurse/nurse_screen_chrome.dart';
import '../../widgets/nurse/room_badge.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<NurseService>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NursePageHeader(
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
                      style: GoogleFonts.inter(color: NurseColors.textSecondary),
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
                            Text(
                              r.patientName!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
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
