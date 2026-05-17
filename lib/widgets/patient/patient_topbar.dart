import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/patient_colors.dart';
import '../../viewmodels/patient/patient_locale_viewmodel.dart';
import 'language_switcher.dart';

class PatientTopbar extends StatelessWidget {
  const PatientTopbar({
    super.key,
    required this.patientName,
    this.notificationCount = 0,
  });

  final String patientName;
  final int notificationCount;

  @override
  Widget build(BuildContext context) {
    context.watch<PatientLocaleViewModel>();
    final now = DateTime.now();
    final dateStr = DateFormat('d MMMM yyyy').format(now);
    final timeStr = DateFormat('HH:mm').format(now);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: PatientColors.topbarBg,
        border: const Border(
          bottom: BorderSide(color: PatientColors.cardBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date & time
          Row(
            children: [
              const Icon(
                Icons.schedule_outlined,
                size: 16,
                color: PatientColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '$dateStr  ·  $timeStr',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: PatientColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Language
          const LanguageSwitcher(),
          const SizedBox(width: 16),

          // Notification bell
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none_outlined,
                size: 22,
                color: PatientColors.textSecondary,
              ),
              if (notificationCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: PatientColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$notificationCount',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [PatientColors.primary, PatientColors.primaryDark],
              ),
            ),
            child: Center(
              child: Text(
                patientName.trim().isEmpty
                    ? '?'
                    : patientName.trim()[0].toUpperCase(),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
