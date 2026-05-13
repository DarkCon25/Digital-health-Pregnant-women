import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/doctor_colors.dart';
import '../../core/app_strings.dart';
import '../../services/doctor_service.dart';
import '../../viewmodels/doctor/doctor_dashboard_viewmodel.dart';
import '../../widgets/doctor/emergency_badge.dart';
import '../../widgets/doctor/doctor_screen_chrome.dart';

class EmergencyAlertsScreen extends StatelessWidget {
  const EmergencyAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DoctorDashboardViewModel>();
    final service = context.read<DoctorService>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DoctorPageHeader(
            title: DoctorStrings.emergencyTitle,
            subtitle: DoctorStrings.emergencyPageSubtitle,
            actions: [
              Chip(
                avatar: Icon(Icons.warning_amber_rounded,
                    size: 18, color: DoctorColors.critical),
                label: Text(
                  '${vm.openAlertsForMyPatients.length} ${DoctorStrings.activeCount}',
                  style: GoogleFonts.inter(
                    color: DoctorColors.critical,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                side: BorderSide(color: DoctorColors.critical.withValues(alpha: 0.4)),
                backgroundColor: DoctorColors.critical.withValues(alpha: 0.08),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _sumCard(
                DoctorStrings.sumOpenAlerts,
                '${vm.openAlertsForMyPatients.length}',
                DoctorColors.critical,
              ),
              _sumCard(
                DoctorStrings.sumCriticalPatients,
                '${vm.criticalCount}',
                DoctorColors.warning,
              ),
              _sumCard(
                DoctorStrings.sumStablePatients,
                '${(vm.totalPatients - vm.criticalCount).clamp(0, 9999)}',
                DoctorColors.success,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: vm.openAlertsForMyPatients.isEmpty
                ? Center(
                    child: Text(
                      DoctorStrings.noOpenAlerts,
                      style: GoogleFonts.inter(
                        color: DoctorColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: vm.openAlertsForMyPatients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final a = vm.openAlertsForMyPatients[i];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: DoctorColors.critical.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const EmergencyBadge(),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.patientName,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${DoctorStrings.roomPrefix}: ${a.roomNumber ?? "—"} • ${a.severity}',
                                    style: GoogleFonts.inter(
                                      color: DoctorColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  service.resolveEmergencyAlert(a.id),
                              child: Text(
                                DoctorStrings.closeAlert,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  color: DoctorColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static Widget _sumCard(String title, String value, Color c) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: DoctorColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}
