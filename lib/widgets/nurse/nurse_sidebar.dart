import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/nurse_colors.dart';
import '../../core/nurse_strings.dart';
import '../app_logo.dart';
import 'nurse_screen_chrome.dart';

enum NursePage {
  dashboard,
  patients,
  vitals,
  medications,
  emergency,
  rooms,
  appointments,
  messages,
  notifications,
  reports,
  settings,
  icu,
  contactDoctor,
}

class NurseSidebar extends StatelessWidget {
  const NurseSidebar({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
    required this.onLogout,
    required this.nurseName,
    this.openEmergencyCount = 0,
    this.notificationBadge = 0,
    this.unreadMessages = 0,
  });

  final NursePage currentPage;
  final ValueChanged<NursePage> onPageChanged;
  final VoidCallback onLogout;
  final String nurseName;
  final int openEmergencyCount;
  final int notificationBadge;
  final int unreadMessages;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: NurseColors.sidebarBg,
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 20,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
            child: Row(
              children: [
                const AppLogo(size: 36, isCircle: false),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        NurseStrings.appName,
                        style: GoogleFonts.inter(
                          color: NurseColors.sidebarText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        NurseStrings.portalSubtitle,
                        style: GoogleFonts.inter(
                          color: NurseColors.sidebarMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: NurseSurfaceCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: NurseColors.primary.withValues(alpha: 0.25),
                    child: Text(
                      nurseName.isNotEmpty ? nurseName[0].toUpperCase() : 'N',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
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
                            color: NurseColors.sidebarText,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          NurseStrings.online,
                          style: GoogleFonts.inter(
                            color: NurseColors.success,
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
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
              children: [
                _section(NurseStrings.navMain),
                _item(Icons.dashboard_outlined, NurseStrings.pageDashboard,
                    NursePage.dashboard),
                _item(Icons.people_outline, NurseStrings.pagePatients,
                    NursePage.patients),
                _item(Icons.monitor_heart_outlined, NurseStrings.pageVitals,
                    NursePage.vitals),
                _item(Icons.medication_outlined, NurseStrings.pageMedications,
                    NursePage.medications),
                _item(Icons.emergency_outlined, NurseStrings.pageEmergency,
                    NursePage.emergency,
                    badge: openEmergencyCount),
                _item(Icons.bed_outlined, NurseStrings.pageRooms, NursePage.rooms),
                _item(Icons.local_hospital_outlined, NurseStrings.pageIcu,
                    NursePage.icu),
                _section(NurseStrings.navCare),
                _item(Icons.calendar_month_outlined,
                    NurseStrings.pageAppointments, NursePage.appointments),
                _section(NurseStrings.navComm),
                _item(Icons.chat_bubble_outline, NurseStrings.pageMessages,
                    NursePage.messages,
                    badge: unreadMessages,
                    dotOnly: true),
                _item(Icons.notifications_outlined,
                    NurseStrings.pageNotifications, NursePage.notifications,
                    badge: notificationBadge),
                _section(NurseStrings.navOther),
                _item(Icons.analytics_outlined, NurseStrings.pageReports,
                    NursePage.reports),
                _item(Icons.settings_outlined, NurseStrings.pageSettings,
                    NursePage.settings),
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
                    NurseStrings.logout,
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
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
        child: Text(
          t,
          style: GoogleFonts.inter(
            color: NurseColors.sidebarMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      );

  Widget _item(
    IconData icon,
    String label,
    NursePage page, {
    int badge = 0,
    bool dotOnly = false,
  }) {
    final selected = currentPage == page;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected
            ? NurseColors.sidebarActive.withValues(alpha: 0.35)
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
                      ? NurseColors.sidebarText
                      : NurseColors.sidebarMuted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      color: selected
                          ? NurseColors.sidebarText
                          : NurseColors.sidebarMuted,
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
                      color: NurseColors.critical,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (badge > 0 && !dotOnly)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: NurseColors.critical,
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
