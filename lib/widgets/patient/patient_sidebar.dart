import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/patient_colors.dart';
import '../../core/localization/patient_strings.dart';
import '../../viewmodels/patient/patient_locale_viewmodel.dart';
import '../app_logo.dart';
import 'language_switcher.dart';

enum PatientPage {
  dashboard,
  medicalFile,
  analyses,
  fetalImages,
  appointments,
  emergency,
  notifications,
  profile,
}

class PatientSidebar extends StatelessWidget {
  const PatientSidebar({
    super.key,
    required this.currentPage,
    required this.onSelect,
    required this.nurseName,
    this.onLogout,
  });

  final PatientPage currentPage;
  final ValueChanged<PatientPage> onSelect;
  final String nurseName;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<PatientLocaleViewModel>().locale;
    final s = PatientL10n.of(locale);

    final items = [
      (PatientPage.dashboard, Icons.home_outlined, s.navDashboard),
      (PatientPage.medicalFile, Icons.folder_outlined, s.navMedicalFile),
      (PatientPage.analyses, Icons.science_outlined, s.navAnalyses),
      (PatientPage.fetalImages, Icons.child_care_outlined, s.navFetalImages),
      (
        PatientPage.appointments,
        Icons.calendar_month_outlined,
        s.navAppointments
      ),
      (PatientPage.emergency, Icons.emergency_outlined, s.navEmergency),
      (
        PatientPage.notifications,
        Icons.notifications_none_outlined,
        s.navNotifications
      ),
      (PatientPage.profile, Icons.person_outline, s.navProfile),
    ];

    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: PatientColors.sidebarBg,
        border: Border(
          right: BorderSide(color: PatientColors.sidebarBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              children: [
                const AppLogo(size: 32),
                const SizedBox(width: 10),
                Text(
                  'HerCare',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: PatientColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Patient avatar + name
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PatientColors.primaryTint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PatientColors.primaryLight),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          PatientColors.primary,
                          PatientColors.primaryDark,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        nurseName.trim().isEmpty
                            ? '?'
                            : nurseName.trim()[0].toUpperCase(),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nurseName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: PatientColors.textPrimary,
                          ),
                        ),
                        Text(
                          s.portalLabel,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: PatientColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: items.map((t) {
                final selected = currentPage == t.$1;
                return _SidebarItem(
                  icon: t.$2,
                  label: t.$3,
                  selected: selected,
                  onTap: () => onSelect(t.$1),
                  isEmergency: t.$1 == PatientPage.emergency,
                );
              }).toList(),
            ),
          ),

          // Language switcher
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(child: LanguageSwitcher(compact: true)),
          ),

          // Logout
          InkWell(
            onTap: onLogout ?? () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.08),
                border: Border(
                  top: BorderSide(
                    color: PatientColors.primary.withValues(alpha: 0.18),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    s.navLogout,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.isEmergency = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isEmergency;

  @override
  Widget build(BuildContext context) {
    Color fgColor;
    Color bgColor;
    if (isEmergency) {
      fgColor = selected ? Colors.white : PatientColors.critical;
      bgColor = selected ? PatientColors.critical : PatientColors.criticalLight;
    } else {
      fgColor = selected ? PatientColors.primary : PatientColors.textSecondary;
      bgColor = selected ? PatientColors.sidebarActiveBg : Colors.transparent;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: fgColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: fgColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
