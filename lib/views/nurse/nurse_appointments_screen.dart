import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/nurse_colors.dart';
import '../../core/nurse_strings.dart';
import '../../services/nurse_service.dart';
import '../../widgets/nurse/nurse_screen_chrome.dart';

class NurseAppointmentsScreen extends StatelessWidget {
  const NurseAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<NurseService>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const NursePageHeader(
            title: NurseStrings.pageAppointments,
            subtitle: NurseStrings.reportsSub,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: NurseSurfaceCard(
              padding: EdgeInsets.zero,
              child: StreamBuilder<QuerySnapshot>(
                stream: service.watchUpcomingAppointments(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snap.data!.docs;
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        NurseStrings.noAppointments,
                        style: GoogleFonts.inter(color: NurseColors.textSecondary),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final m = docs[i].data()! as Map<String, dynamic>;
                      final name = m['patientName']?.toString() ?? '';
                      final start = m['startAt'] ?? m['dateTime'];
                      String when = '';
                      if (start is Timestamp) {
                        when = DateFormat.yMMMd()
                            .add_Hm()
                            .format(start.toDate());
                      }
                      return ListTile(
                        title: Text(name,
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                        subtitle: Text(when),
                        trailing: Chip(
                          label: Text(m['status']?.toString() ?? ''),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
