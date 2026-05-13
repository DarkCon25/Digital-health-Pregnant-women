import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/patient_colors.dart';
import '../../viewmodels/patient/patient_locale_viewmodel.dart';

/// Language switcher widget for the patient portal (AR / FR / EN).
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PatientLocaleViewModel>();

    final langs = [
      ('fr', 'FR'),
      ('en', 'EN'),
      ('ar', 'ع'),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: langs.map((l) {
        final selected = vm.locale == l.$1;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: GestureDetector(
            onTap: () => vm.setLocale(l.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: selected
                    ? PatientColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? PatientColors.primary
                      : PatientColors.cardBorder,
                ),
              ),
              child: Text(
                l.$2,
                style: GoogleFonts.inter(
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? Colors.white
                      : PatientColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
