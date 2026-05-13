import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/nurse_colors.dart';
import '../../models/doctor/medical_file_model.dart';

class VitalSignsWidget extends StatelessWidget {
  const VitalSignsWidget({super.key, required this.medical});

  final MedicalFileModel medical;

  @override
  Widget build(BuildContext context) {
    final items = <_V>[];
    if (medical.bloodPressureSystolic != null ||
        medical.bloodPressureDiastolic != null) {
      items.add(_V(
        'BP',
        '${medical.bloodPressureSystolic ?? '—'}/${medical.bloodPressureDiastolic ?? '—'}',
        Icons.favorite_outline,
      ));
    }
    items.add(_V('HR', '${medical.heartRateBpm ?? '—'}', Icons.monitor_heart_outlined));
    items.add(_V(
      'Temp',
      medical.temperatureCelsius != null
          ? '${medical.temperatureCelsius!.toStringAsFixed(1)}°C'
          : '—',
      Icons.thermostat_outlined,
    ));
    items.add(_V(
      'Glucose',
      medical.bloodGlucose != null ? '${medical.bloodGlucose}' : '—',
      Icons.bloodtype_outlined,
    ));

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items
          .map(
            (e) => Container(
              width: 120,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: NurseColors.tint,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: NurseColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(e.icon, size: 20, color: NurseColors.primary),
                  const SizedBox(height: 8),
                  Text(
                    e.label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: NurseColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    e.value,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _V {
  _V(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;
}
