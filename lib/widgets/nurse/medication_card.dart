import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/nurse_colors.dart';
import '../../core/nurse_strings.dart';
import '../../models/nurse/medication_schedule_model.dart';

class MedicationCard extends StatelessWidget {
  const MedicationCard({
    super.key,
    required this.item,
    this.onMarkAdministered,
  });

  final MedicationScheduleModel item;
  final VoidCallback? onMarkAdministered;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.Hm();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NurseColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.medicationName,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.dosage} • ${item.route} • ${fmt.format(item.scheduledAt)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: NurseColors.textSecondary,
                  ),
                ),
                Text(
                  item.patientName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: NurseColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Chip(
            label: Text(
              item.isAdministered
                  ? NurseStrings.administered
                  : NurseStrings.pending,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: item.isAdministered
                    ? NurseColors.success
                    : NurseColors.warning,
              ),
            ),
            side: BorderSide(
              color: item.isAdministered
                  ? NurseColors.success
                  : NurseColors.warning,
            ),
            backgroundColor: item.isAdministered
                ? NurseColors.success.withValues(alpha: 0.1)
                : NurseColors.warning.withValues(alpha: 0.1),
          ),
          if (!item.isAdministered && onMarkAdministered != null)
            IconButton(
              tooltip: NurseStrings.administered,
              onPressed: onMarkAdministered,
              icon: const Icon(Icons.check_circle_outline),
              color: NurseColors.success,
            ),
        ],
      ),
    );
  }
}
