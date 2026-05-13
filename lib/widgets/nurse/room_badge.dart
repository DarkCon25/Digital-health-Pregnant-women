import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/nurse_colors.dart';
import '../../core/nurse_strings.dart';

class RoomBadge extends StatelessWidget {
  const RoomBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    late Color bg;
    late Color fg;
    late String label;
    if (s == 'occupied') {
      bg = NurseColors.critical.withValues(alpha: 0.12);
      fg = NurseColors.critical;
      label = NurseStrings.roomOccupied;
    } else if (s == 'maintenance' || s == 'cleaning') {
      bg = NurseColors.warning.withValues(alpha: 0.15);
      fg = NurseColors.warning;
      label = NurseStrings.roomMaintenance;
    } else {
      bg = NurseColors.success.withValues(alpha: 0.12);
      fg = NurseColors.success;
      label = NurseStrings.roomAvailable;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
