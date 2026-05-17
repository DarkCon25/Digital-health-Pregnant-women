import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/patient_colors.dart';
import '../../core/localization/patient_strings.dart';
import '../../models/patient/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appt,
    required this.locale,
  });

  final AppointmentModel appt;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final s = PatientL10n.of(locale);
    final day = DateFormat('d').format(appt.dateTime);
    final monthAbbr = DateFormat('MMM').format(appt.dateTime);
    final time = DateFormat('HH:mm').format(appt.dateTime);

    Color statusColor;
    String statusLabel;
    switch (appt.status) {
      case 'confirmed':
        statusColor = PatientColors.success;
        statusLabel = s.statusConfirmed;
        break;
      case 'completed':
        statusColor = PatientColors.blue;
        statusLabel = s.statusCompleted;
        break;
      case 'cancelled':
        statusColor = PatientColors.critical;
        statusLabel = s.statusCancelled;
        break;
      default:
        statusColor = PatientColors.warning;
        statusLabel = s.statusPending;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PatientColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date box
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: PatientColors.primaryTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PatientColors.primaryLight),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: PatientColors.primary,
                  ),
                ),
                Text(
                  monthAbbr,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: PatientColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appt.type,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: PatientColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${s.appointmentWith} ${appt.doctorName}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: PatientColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 12,
                      color: PatientColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: PatientColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withValues(alpha: 0.25)),
            ),
            child: Text(
              statusLabel,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
