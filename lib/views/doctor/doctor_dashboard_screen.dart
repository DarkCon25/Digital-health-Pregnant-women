import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_strings.dart';
import '../../core/doctor_colors.dart';
import '../../core/routes.dart';
import '../../models/patient_model.dart';
import '../../services/doctor_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/doctor/doctor_dashboard_viewmodel.dart';
import '../../viewmodels/doctor/my_patients_viewmodel.dart';
import '../../widgets/doctor/doctor_fl_chart.dart';
import '../../widgets/doctor/doctor_sidebar.dart';
import '../../widgets/doctor/doctor_summary_card.dart';
import '../../widgets/doctor/doctor_topbar.dart';
import '../../widgets/doctor/doctor_screen_chrome.dart';
import '../../widgets/responsive_dashboard_shell.dart';
import 'add_patient_screen.dart';
import 'appointments_screen.dart';
import 'doctor_fetal_images_screen.dart';
import 'doctor_icu_screen.dart';
import 'doctor_labor_rooms_screen.dart';
import 'doctor_messages_screen.dart';
import 'doctor_monitoring_screen.dart';
import 'doctor_notifications_screen.dart';
import 'doctor_reports_screen.dart';
import 'doctor_settings_screen.dart';
import 'emergency_alerts_screen.dart';
import 'my_patients_screen.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (c) => DoctorDashboardViewModel(c.read<DoctorService>()),
        ),
        ChangeNotifierProvider(
          create: (c) => MyPatientsViewModel(c.read<DoctorService>()),
        ),
      ],
      child: const _DoctorShell(),
    );
  }
}

class _DoctorShell extends StatefulWidget {
  const _DoctorShell();

  @override
  State<_DoctorShell> createState() => _DoctorShellState();
}

class _DoctorShellState extends State<_DoctorShell> {
  DoctorPage _page = DoctorPage.dashboard;
  String _topSearch = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthViewModel>().currentUser?.uid ??
          FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      context.read<DoctorDashboardViewModel>().start(uid);
      context.read<MyPatientsViewModel>().start(uid);
    });
  }

  String get _doctorName {
    final u = context.read<AuthViewModel>().currentUser;
    if (u != null) {
      return '${DoctorStrings.doctorPrefix}${u.fullName}';
    }
    final n = FirebaseAuth.instance.currentUser?.displayName;
    if (n != null && n.isNotEmpty) return n;
    return DoctorStrings.doctorFallbackName;
  }

  String _title(DoctorPage p) {
    switch (p) {
      case DoctorPage.dashboard:
        return DoctorStrings.pageDashboard;
      case DoctorPage.myPatients:
        return DoctorStrings.pagePatients;
      case DoctorPage.monitoring:
        return DoctorStrings.pageMonitoring;
      case DoctorPage.fetalImages:
        return DoctorStrings.pageUltrasound;
      case DoctorPage.laborRooms:
        return DoctorStrings.pageLaborRooms;
      case DoctorPage.icuCases:
        return DoctorStrings.pageIcu;
      case DoctorPage.reports:
        return DoctorStrings.pageReports;
      case DoctorPage.appointments:
        return DoctorStrings.pageAppointments;
      case DoctorPage.messages:
        return DoctorStrings.pageMessages;
      case DoctorPage.notifications:
        return DoctorStrings.pageNotifications;
      case DoctorPage.settings:
        return DoctorStrings.pageSettings;
      case DoctorPage.addPatient:
        return DoctorStrings.pageAddPatient;
      case DoctorPage.emergency:
        return DoctorStrings.pageEmergency;
    }
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DoctorDashboardViewModel>();
    final emergencyCount = dash.openAlertsForMyPatients.length;
    final messagesService = context.read<DoctorService>();

    return StreamBuilder<int>(
      stream: messagesService.totalUnreadMessagesStream(),
      builder: (context, snap) {
        final unreadMessages = snap.data ?? 0;
        return Scaffold(
          backgroundColor: DoctorColors.pageBg,
          body: Directionality(
            textDirection: ui.TextDirection.ltr,
            child: ResponsiveDashboardShell(
              sidebarWidth: 268,
              minMainWidth: 640,
              sidebar: DoctorSidebar(
                currentPage: _page,
                openEmergencyCount: emergencyCount,
                unreadMessages: unreadMessages,
                onPageChanged: (p) => setState(() => _page = p),
                onLogout: _logout,
              ),
              main: Column(
                children: [
                  DoctorTopBar(
                    title: _title(_page),
                    doctorName: _doctorName,
                    specialtySubtitle: DoctorStrings.specialtyFallback,
                    openEmergencyCount: emergencyCount,
                    onEmergencyTap: () =>
                        setState(() => _page = DoctorPage.emergency),
                    onNotificationsTap: () =>
                        setState(() => _page = DoctorPage.notifications),
                    onSearchChanged: (s) => setState(() => _topSearch = s),
                  ),
                  Expanded(
                    child: Container(
                      color: DoctorColors.pageBg,
                      child: _buildPage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPage() {
    switch (_page) {
      case DoctorPage.dashboard:
        return _DashboardHomeTab(searchQuery: _topSearch);
      case DoctorPage.myPatients:
        return const MyPatientsScreen();
      case DoctorPage.monitoring:
        return const DoctorMonitoringScreen();
      case DoctorPage.fetalImages:
        return const DoctorFetalImagesScreen();
      case DoctorPage.laborRooms:
        return const DoctorLaborRoomsScreen();
      case DoctorPage.icuCases:
        return const DoctorIcuScreen();
      case DoctorPage.reports:
        return const DoctorReportsScreen();
      case DoctorPage.appointments:
        return const AppointmentsScreen();
      case DoctorPage.messages:
        return const DoctorMessagesScreen();
      case DoctorPage.notifications:
        return const DoctorNotificationsScreen();
      case DoctorPage.settings:
        return const DoctorSettingsScreen();
      case DoctorPage.addPatient:
        return const AddPatientScreen();
      case DoctorPage.emergency:
        return const EmergencyAlertsScreen();
    }
  }
}

class _DashboardHomeTab extends StatelessWidget {
  const _DashboardHomeTab({this.searchQuery = ''});

  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DoctorDashboardViewModel>();
    final q = searchQuery.trim().toLowerCase();
    final tablePatients = q.isEmpty
        ? vm.patients
        : vm.patients
            .where((p) =>
                p.fullName.toLowerCase().contains(q) ||
                p.uid.toLowerCase().contains(q))
            .toList();

    if (vm.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            vm.error!,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: DoctorColors.critical),
          ),
        ),
      );
    }

    final spotlight = vm.spotlightPatient;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DoctorPageHeader(
            title: DoctorStrings.pageDashboard,
            subtitle: DoctorStrings.dashboardPageSubtitle,
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final cols = w > 1200 ? 4 : (w > 720 ? 2 : 1);
              double cell() =>
                  cols == 1 ? w : (w - (cols - 1) * 16) / cols;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: cell(),
                    child: DoctorSummaryCard(
                      title: DoctorStrings.statTotalPatients,
                      value: '${vm.totalPatients}',
                      icon: Icons.groups_2_outlined,
                      accentColor: DoctorColors.primary,
                    ),
                  ),
                  SizedBox(
                    width: cell(),
                    child: DoctorSummaryCard(
                      title: DoctorStrings.statCriticalCases,
                      value: '${vm.criticalCount}',
                      icon: Icons.emergency_outlined,
                      accentColor: DoctorColors.critical,
                    ),
                  ),
                  SizedBox(
                    width: cell(),
                    child: DoctorSummaryCard(
                      title: DoctorStrings.statPatientsWithRoom,
                      value: '${vm.patientsInHospitalCount}',
                      icon: Icons.bed_outlined,
                      accentColor: DoctorColors.accentBlue,
                    ),
                  ),
                  SizedBox(
                    width: cell(),
                    child: DoctorSummaryCard(
                      title: DoctorStrings.statNewAlerts,
                      value: '${vm.newAlertsCount}',
                      icon: Icons.notifications_active_outlined,
                      accentColor: DoctorColors.warning,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: DoctorSurfaceCard(
                  padding: const EdgeInsets.all(22),
                  child: DoctorFlMonitoringChart(
                    rows: vm.chartRows,
                    primaryKey: 'weight',
                    secondaryKey: 'sugarLevel',
                    title: DoctorStrings.chartFollowUpTitle,
                    height: 240,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (spotlight != null)
                Expanded(
                  flex: 2,
                  child: _SpotlightPatientCard(patientId: spotlight.uid),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            DoctorStrings.ultrasoundPreview,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: vm.recentUltrasounds.isEmpty
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      DoctorStrings.noUltrasoundImages,
                      style: GoogleFonts.inter(
                        color: DoctorColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: vm.recentUltrasounds.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final u = vm.recentUltrasounds[i];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 1.4,
                          child: u.imageUrl.isEmpty
                              ? Container(
                                  color: DoctorColors.lavenderTint,
                                  child: const Icon(Icons.image),
                                )
                              : Image.network(
                                  u.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: DoctorColors.lavenderTint,
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),
          Text(
            DoctorStrings.recentPatients,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          DoctorSurfaceCard(
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  DoctorColors.lavenderTint,
                ),
                columns: const [
                  DataColumn(label: Text(DoctorStrings.colPatient)),
                  DataColumn(label: Text(DoctorStrings.colDate)),
                  DataColumn(label: Text(DoctorStrings.colRoom)),
                  DataColumn(label: Text(DoctorStrings.colStatus)),
                  DataColumn(label: Text('')),
                ],
                rows: tablePatients.take(14).map((p) {
                  final st = p.status.toLowerCase();
                  final chipColor = st == 'critical'
                      ? DoctorColors.critical
                      : DoctorColors.success;
                  return DataRow(
                    cells: [
                      DataCell(Text(p.fullName)),
                      DataCell(Text(
                        DateFormat.yMMMd().format(p.createdAt),
                      )),
                      DataCell(Text(p.roomNumber ?? '—')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: chipColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            p.status,
                            style: GoogleFonts.inter(
                              color: chipColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.doctorMedicalFile,
                              arguments: p.uid,
                            );
                          },
                          child: const Text(DoctorStrings.colFile),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightPatientCard extends StatelessWidget {
  const _SpotlightPatientCard({required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DoctorDashboardViewModel>();
    PatientModel? p;
    for (final x in vm.patients) {
      if (x.uid == patientId) {
        p = x;
        break;
      }
    }
    if (p == null) return const SizedBox.shrink();
    final patient = p;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.doctorMedicalFile,
            arguments: patientId,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: DoctorColors.primary.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DoctorStrings.spotlightActive,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: DoctorColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                patient.fullName,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DoctorStrings.gestWeekAndBlood(
                  patient.gestationalWeek ?? patient.pregnancyWeek ?? '—',
                  patient.bloodType ?? '—',
                ),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: DoctorColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${DoctorStrings.spotlightStatus}: ${patient.status}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: DoctorColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
