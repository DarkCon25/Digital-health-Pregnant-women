import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/doctor_colors.dart';
import '../../core/app_strings.dart';
import '../app_logo.dart';

enum DoctorPage {
  dashboard,
  myPatients,
  monitoring,
  fetalImages,
  laborRooms,
  icuCases,
  reports,
  appointments,
  messages,
  notifications,
  settings,
  addPatient,
  emergency,
}

class DoctorSidebar extends StatelessWidget {
  const DoctorSidebar({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
    required this.onLogout,
    this.openEmergencyCount = 0,
    this.unreadMessages = 0,
  });

  final DoctorPage currentPage;
  final ValueChanged<DoctorPage> onPageChanged;
  final VoidCallback onLogout;
  final int openEmergencyCount;
  final int unreadMessages;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 268,
      decoration: const BoxDecoration(
        color: DoctorColors.sidebarBg,
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 26, 18, 18),
            child: Row(
              children: [
                const AppLogo(size: 40, isCircle: false),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DoctorStrings.appNameHerCare,
                        style: GoogleFonts.inter(
                          color: DoctorColors.sidebarText,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        DoctorStrings.doctorPortalSubtitle,
                        style: GoogleFonts.inter(
                          color: DoctorColors.sidebarMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
              children: [
                _section(DoctorStrings.navMain),
                _item(Icons.dashboard_outlined, DoctorStrings.pageDashboard,
                    DoctorPage.dashboard),
                _item(Icons.people_outline, DoctorStrings.pagePatients,
                    DoctorPage.myPatients),
                _item(Icons.show_chart, DoctorStrings.pageMonitoring,
                    DoctorPage.monitoring),
                _item(Icons.image_outlined, DoctorStrings.pageUltrasound,
                    DoctorPage.fetalImages),
                _item(Icons.bed_outlined, DoctorStrings.pageLaborRooms,
                    DoctorPage.laborRooms),
                _item(Icons.monitor_heart_outlined, DoctorStrings.pageIcu,
                    DoctorPage.icuCases),
                _item(Icons.description_outlined, DoctorStrings.pageReports,
                    DoctorPage.reports),
                _section(DoctorStrings.navCommunication),
                _item(Icons.calendar_month_outlined,
                    DoctorStrings.pageAppointments, DoctorPage.appointments),
                _item(Icons.chat_bubble_outline, DoctorStrings.pageMessages,
                    DoctorPage.messages,
                    badge: unreadMessages,
                    dotOnly: true),
                _item(Icons.notifications_outlined,
                    DoctorStrings.pageNotifications, DoctorPage.notifications),
                _section(DoctorStrings.navOther),
                _item(Icons.settings_outlined, DoctorStrings.pageSettings,
                    DoctorPage.settings),
                _item(Icons.person_add_alt_1_outlined,
                    DoctorStrings.pageAddPatient, DoctorPage.addPatient),
                _item(
                  Icons.emergency_outlined,
                  DoctorStrings.pageEmergency,
                  DoctorPage.emergency,
                  badge: openEmergencyCount,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onLogout,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    DoctorStrings.logout,
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

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            t,
            style: GoogleFonts.inter(
              color: DoctorColors.sidebarMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );

  Widget _item(
    IconData icon,
    String label,
    DoctorPage page, {
    int badge = 0,
    bool dotOnly = false,
  }) {
    final selected = currentPage == page;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected
            ? DoctorColors.sidebarActive.withValues(alpha: 0.22)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onPageChanged(page),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected
                      ? DoctorColors.sidebarText
                      : DoctorColors.sidebarMuted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      color: selected
                          ? DoctorColors.sidebarText
                          : DoctorColors.sidebarMuted,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (badge > 0 && dotOnly)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: DoctorColors.critical,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (badge > 0 && !dotOnly)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: DoctorColors.critical,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$badge',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
