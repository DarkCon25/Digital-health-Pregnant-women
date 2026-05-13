import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/doctor_colors.dart';
import '../../models/patient_model.dart';
import 'emergency_badge.dart';

class PatientListItem extends StatelessWidget {
  const PatientListItem({
    super.key,
    required this.patient,
    required this.onOpenFile,
  });

  final PatientModel patient;
  final VoidCallback onOpenFile;

  @override
  Widget build(BuildContext context) {
    final critical = patient.status.toLowerCase() == 'critical';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onOpenFile,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DoctorColors.cardBorder),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    DoctorColors.primary.withValues(alpha: 0.15),
                child: Text(
                  patient.firstName.isNotEmpty
                      ? patient.firstName[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: DoctorColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: DoctorColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      patient.email,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: DoctorColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  patient.roomNumber ?? '—',
                  style: GoogleFonts.inter(
                    color: DoctorColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '${patient.age ?? "—"}',
                  style: GoogleFonts.inter(
                    color: DoctorColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              if (critical)
                const EmergencyBadge()
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: DoctorColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    patient.status,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: DoctorColors.success,
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: onOpenFile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
