import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/nurse_colors.dart';
import '../../core/nurse_strings.dart';
import '../../services/nurse_service.dart';
import '../../viewmodels/nurse/medications_viewmodel.dart';
import '../../widgets/nurse/medication_card.dart';
import '../../widgets/nurse/nurse_screen_chrome.dart';

class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MedicationsViewModel>();
    final service = context.read<NurseService>();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final name = FirebaseAuth.instance.currentUser?.displayName ?? 'Nurse';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NursePageHeader(
            title: NurseStrings.pageMedications,
            subtitle: NurseStrings.tabAllMeds,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ActionChip(
                label: Text(NurseStrings.tabDueToday),
                onPressed: () => vm.setTab(0),
                backgroundColor:
                    vm.tabIndex == 0 ? NurseColors.primary.withValues(alpha: 0.2) : null,
              ),
              const SizedBox(width: 8),
              ActionChip(
                label: Text(NurseStrings.tabAllMeds),
                onPressed: () => vm.setTab(1),
                backgroundColor:
                    vm.tabIndex == 1 ? NurseColors.primary.withValues(alpha: 0.2) : null,
              ),
              const SizedBox(width: 8),
              ActionChip(
                label: Text(NurseStrings.tabAdministered),
                onPressed: () => vm.setTab(2),
                backgroundColor:
                    vm.tabIndex == 2 ? NurseColors.primary.withValues(alpha: 0.2) : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: vm.filtered.isEmpty
                ? Center(
                    child: Text(
                      NurseStrings.noMedications,
                      style: GoogleFonts.inter(color: NurseColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    itemCount: vm.filtered.length,
                    itemBuilder: (context, i) {
                      final m = vm.filtered[i];
                      return MedicationCard(
                        item: m,
                        onMarkAdministered: m.isAdministered || uid.isEmpty
                            ? null
                            : () => service.markMedicationAdministered(
                                  scheduleId: m.id,
                                  nurseId: uid,
                                  nurseName: name,
                                ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
