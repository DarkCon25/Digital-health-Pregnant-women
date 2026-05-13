import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_strings.dart';
import '../../core/doctor_colors.dart';

/// Red pulsing badge for critical / emergency rows.
class EmergencyBadge extends StatefulWidget {
  const EmergencyBadge({super.key, this.label = DoctorStrings.emergencyBadge});

  final String label;

  @override
  State<EmergencyBadge> createState() => _EmergencyBadgeState();
}

class _EmergencyBadgeState extends State<EmergencyBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final o = 0.55 + 0.45 * _c.value;
        return Opacity(
          opacity: o,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: DoctorColors.critical.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: DoctorColors.critical),
        ),
        child: Text(
          widget.label,
          style: GoogleFonts.inter(
            color: DoctorColors.critical,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
