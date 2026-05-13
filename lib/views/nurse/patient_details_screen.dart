import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/nurse_colors.dart';
import '../../core/nurse_strings.dart';
import '../../models/nurse/nurse_patient_model.dart';
import '../../services/nurse_service.dart';
import '../../widgets/nurse/nurse_screen_chrome.dart';

class PatientDetailsScreen extends StatelessWidget {
  const PatientDetailsScreen({
    super.key,
    required this.patientId,
    this.onMonitor,
    this.onBack,
  });

  final String patientId;
  final VoidCallback? onMonitor;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final service = context.read<NurseService>();

    return FutureBuilder<NursePatientModel?>(
      future: service.getPatient(patientId),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final p = snap.data;
        if (p == null) {
          return Center(child: Text(NurseStrings.noPatients));
        }
        final pat = p.patient;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (onBack != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack,
                  ),
                ),
              NursePageHeader(
                title: NurseStrings.pagePatientDetails,
                subtitle: pat.fullName,
                actions: [
                  if (onMonitor != null)
                    FilledButton.icon(
                      onPressed: onMonitor,
                      icon: const Icon(Icons.monitor_heart_outlined),
                      label: Text(NurseStrings.pageVitals),
                      style: FilledButton.styleFrom(
                        backgroundColor: NurseColors.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              NurseSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row('Email', pat.email),
                    _row('Phone', pat.phone),
                    _row('Status', pat.status),
                    _row('Room', pat.roomNumber ?? '—'),
                    _row('Blood', pat.bloodType ?? '—'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              k,
              style: GoogleFonts.inter(
                color: NurseColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(v, style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
