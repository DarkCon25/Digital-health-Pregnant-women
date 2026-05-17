import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/nurse_colors.dart';
import '../../core/nurse_strings.dart';
import '../../models/doctor/icu_case_model.dart';
import '../../services/nurse_service.dart';
import '../../widgets/nurse/nurse_screen_chrome.dart';

class IntensiveCareScreen extends StatelessWidget {
  const IntensiveCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<NurseService>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const NursePageHeader(
            title: NurseStrings.pageIcu,
            subtitle: NurseStrings.statIcu,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<IcuCaseModel>>(
              stream: service.watchIcuCases(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final cases = snap.data!;
                if (cases.isEmpty) {
                  return Center(
                    child: Text(
                      NurseStrings.noIcuCases,
                      style: GoogleFonts.inter(color: NurseColors.textSecondary),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: cases.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final c = cases[i];
                    return NurseSurfaceCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.patientName,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            c.reason,
                            style: GoogleFonts.inter(
                              color: NurseColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${NurseStrings.colStatus}: ${c.status}',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          if (c.admittedAt != null)
                            Text(
                              DateFormat.yMMMd().add_Hm().format(c.admittedAt!),
                              style: GoogleFonts.inter(fontSize: 12),
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
