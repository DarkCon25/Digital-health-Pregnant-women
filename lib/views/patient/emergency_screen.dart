import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/localization/patient_strings.dart';
import '../../core/patient_colors.dart';
import '../../models/patient/emergency_alert_model.dart';
import '../../services/patient_service.dart';
import '../../viewmodels/patient/patient_dashboard_viewmodel.dart';
import '../../widgets/patient/emergency_button.dart';
import '../../widgets/patient/patient_screen_chrome.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({
    super.key,
    required this.locale,
    required this.patientId,
  });

  final String locale;
  final String patientId;

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _sending = false;
  bool _sent = false;
  String? _error;

  Future<void> _sendAlert() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final dashVm = context.read<PatientDashboardViewModel>();
      final patient = dashVm.patient;
      final svc = context.read<PatientService>();

      await svc.sendEmergencyAlert(
        EmergencyAlertModel(
          id: '',
          patientId: widget.patientId,
          patientName: patient?.fullName ?? '',
          roomNumber: patient?.roomNumber,
          status: 'open',
          createdAt: DateTime.now(),
        ),
      );
      if (mounted) {
        setState(() {
          _sending = false;
          _sent = true;
        });
        await Future<void>.delayed(const Duration(seconds: 5));
        if (mounted) setState(() => _sent = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sending = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = PatientL10n.of(widget.locale);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PatientPageHeader(
            title: s.emergencyTitle,
            subtitle: s.emergencySub,
          ),
          const SizedBox(height: 40),

          // ── Red alert card
          PatientCard(
            color: PatientColors.criticalLight,
            child: Column(
              children: [
                // Pulse icon
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.9, end: 1.1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  builder: (_, v, child) => Transform.scale(
                    scale: v,
                    child: child,
                  ),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PatientColors.critical.withValues(alpha: 0.15),
                      border: Border.all(
                        color: PatientColors.critical.withValues(alpha: 0.4),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.local_hospital,
                      size: 52,
                      color: PatientColors.critical,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  s.emergencyNeedHelp,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: PatientColors.critical,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  s.emergencyDesc,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: PatientColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.emergencyLocationNote,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: PatientColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 32),

                // Button
                if (_sent)
                  Column(
                    children: [
                      const Icon(Icons.check_circle,
                          color: PatientColors.success, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        s.emergencySent,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: PatientColors.success,
                        ),
                      ),
                    ],
                  )
                else
                  EmergencyButton(
                    label: s.emergencyCallBtn,
                    loading: _sending,
                    sent: _sent,
                    onPressed: _sendAlert,
                  ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    s.emergencyError,
                    style: GoogleFonts.inter(
                      color: PatientColors.critical,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
