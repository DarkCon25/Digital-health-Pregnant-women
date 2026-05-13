import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/nurse_colors.dart';
import '../../core/nurse_strings.dart';
import '../../models/nurse/emergency_request_model.dart';
import '../../viewmodels/nurse/emergency_viewmodel.dart';
import '../../widgets/nurse/emergency_button.dart';
import '../../widgets/nurse/nurse_screen_chrome.dart';
import '../../widgets/responsive_dashboard_shell.dart';

class EmergencyRequestsScreen extends StatelessWidget {
  const EmergencyRequestsScreen({
    super.key,
    required this.onContactDoctor,
  });

  final void Function(String patientId, String patientName) onContactDoctor;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmergencyViewModel>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NursePageHeader(
            title: NurseStrings.pageEmergency,
            subtitle: '${vm.open.length} ${NurseStrings.pending}',
          ),
          const SizedBox(height: 16),
          Expanded(
            child: vm.open.isEmpty
                ? Center(
                    child: Text(
                      NurseStrings.noAlerts,
                      style: GoogleFonts.inter(color: NurseColors.textSecondary),
                    ),
                  )
                : ResponsiveHorizontalSplit(
                    leftWidth: 300,
                    minRightWidth: 400,
                    between: const VerticalDivider(width: 1),
                    betweenWidth: 1,
                    left: NurseSurfaceCard(
                      padding: EdgeInsets.zero,
                      child: ListView.builder(
                        itemCount: vm.open.length,
                        itemBuilder: (context, i) {
                          final e = vm.open[i];
                          final sel = vm.selected?.id == e.id;
                          return ListTile(
                            selected: sel,
                            title: Text(
                              e.patientName,
                              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(e.reason ?? ''),
                            onTap: () => vm.select(e),
                          );
                        },
                      ),
                    ),
                    right: vm.selected == null
                        ? const SizedBox.shrink()
                        : _DetailPanel(
                            e: vm.selected!,
                            onResolve: () => vm.resolveSelected(),
                            onContactDoctor: () => onContactDoctor(
                              vm.selected!.patientId,
                              vm.selected!.patientName,
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
    required this.e,
    required this.onResolve,
    required this.onContactDoctor,
  });

  final EmergencyRequestModel e;
  final VoidCallback onResolve;
  final VoidCallback onContactDoctor;

  @override
  Widget build(BuildContext context) {
    return NurseSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            e.patientName,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (e.roomNumber != null)
            Text(
              '${NurseStrings.colRoom}: ${e.roomNumber}',
              style: GoogleFonts.inter(color: NurseColors.textSecondary),
            ),
          const SizedBox(height: 12),
          Text(
            e.reason ?? '—',
            style: GoogleFonts.inter(fontSize: 15, height: 1.4),
          ),
          const Spacer(),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              EmergencyButton(
                label: NurseStrings.contactDoctor,
                filled: true,
                onPressed: onContactDoctor,
              ),
              EmergencyButton(
                label: NurseStrings.markResolved,
                onPressed: onResolve,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
