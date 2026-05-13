import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/nurse_colors.dart';
import '../../core/nurse_strings.dart';
import '../../viewmodels/nurse/nurse_dashboard_viewmodel.dart';
import '../../widgets/nurse/nurse_screen_chrome.dart';

class NurseReportsScreen extends StatelessWidget {
  const NurseReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<NurseDashboardViewModel>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NursePageHeader(
            title: NurseStrings.pageReports,
            subtitle: NurseStrings.reportsSub,
            actions: [
              IconButton.filledTonal(
                onPressed: () =>
                    context.read<NurseDashboardViewModel>().refreshCounts(),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: dash.counts == null
                ? const Center(child: CircularProgressIndicator())
                : GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _tile(NurseStrings.statTotalPatients,
                          '${dash.counts!['patients']}', Icons.people_outline),
                      _tile(NurseStrings.statCritical,
                          '${dash.counts!['critical']}', Icons.emergency_outlined),
                      _tile(NurseStrings.statIcu, '${dash.counts!['icu']}',
                          Icons.local_hospital_outlined),
                      _tile(NurseStrings.statBirths,
                          '${dash.counts!['birthsToday']}', Icons.child_care_outlined),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tile(String title, String value, IconData icon) {
    return NurseSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: NurseColors.primary, size: 28),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: NurseColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: NurseColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
