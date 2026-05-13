import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/nurse_colors.dart';
import '../../core/nurse_strings.dart';
import '../../core/routes.dart';
import '../../models/nurse/emergency_request_model.dart';
import '../../services/nurse_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/nurse/emergency_viewmodel.dart';
import '../../viewmodels/nurse/medications_viewmodel.dart';
import '../../viewmodels/nurse/nurse_dashboard_viewmodel.dart';
import '../../viewmodels/nurse/nurse_patients_viewmodel.dart';
import '../../widgets/nurse/nurse_screen_chrome.dart';
import '../../widgets/nurse/nurse_sidebar.dart';
import '../../widgets/nurse/nurse_topbar.dart';
import '../../widgets/nurse/patient_status_card.dart';
import '../../widgets/responsive_dashboard_shell.dart';
import 'contact_doctor_screen.dart';
import 'emergency_requests_screen.dart';
import 'intensive_care_screen.dart';
import 'medications_screen.dart';
import 'nurse_appointments_screen.dart';
import 'nurse_messages_screen.dart';
import 'nurse_notifications_screen.dart';
import 'nurse_reports_screen.dart';
import 'nurse_settings_screen.dart';
import 'patient_details_screen.dart';
import 'patient_monitoring_screen.dart';
import 'patients_list_screen.dart';
import 'rooms_screen.dart';

class NurseDashboardScreen extends StatelessWidget {
  const NurseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NurseDashboardViewModel(context.read<NurseService>()),
        ),
        ChangeNotifierProvider(
          create: (_) => NursePatientsViewModel(context.read<NurseService>()),
        ),
        ChangeNotifierProvider(
          create: (_) => EmergencyViewModel(context.read<NurseService>()),
        ),
        ChangeNotifierProvider(
          create: (_) => MedicationsViewModel(context.read<NurseService>()),
        ),
      ],
      child: const _NurseShell(),
    );
  }
}

class _NurseShell extends StatefulWidget {
  const _NurseShell();

  @override
  State<_NurseShell> createState() => _NurseShellState();
}

class _NurseShellState extends State<_NurseShell> {
  NursePage _page = NursePage.dashboard;
  String _topSearch = '';
  String? _vitalsPatientId;
  String? _detailsPatientId;
  String? _contactPatientId;
  String? _contactPatientName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NurseDashboardViewModel>().start();
      context.read<NursePatientsViewModel>().start();
      context.read<EmergencyViewModel>().start();
      context.read<MedicationsViewModel>().start();
    });
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

  String _title(NursePage p) {
    switch (p) {
      case NursePage.dashboard:
        return NurseStrings.pageDashboard;
      case NursePage.patients:
        return NurseStrings.pagePatients;
      case NursePage.vitals:
        return NurseStrings.pageVitals;
      case NursePage.medications:
        return NurseStrings.pageMedications;
      case NursePage.emergency:
        return NurseStrings.pageEmergency;
      case NursePage.rooms:
        return NurseStrings.pageRooms;
      case NursePage.appointments:
        return NurseStrings.pageAppointments;
      case NursePage.messages:
        return NurseStrings.pageMessages;
      case NursePage.notifications:
        return NurseStrings.pageNotifications;
      case NursePage.reports:
        return NurseStrings.pageReports;
      case NursePage.settings:
        return NurseStrings.pageSettings;
      case NursePage.icu:
        return NurseStrings.pageIcu;
      case NursePage.contactDoctor:
        return NurseStrings.pageContactDoctor;
    }
  }

  int _notifBadge() {
    // lightweight: emergency open count as badge on sidebar notifications is separate stream in topbar
    return context.read<EmergencyViewModel>().open.length.clamp(0, 99);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final emergencyVm = context.watch<EmergencyViewModel>();
    final messagesService = context.read<NurseService>();
    final name = auth.currentUser?.fullName ??
        FirebaseAuth.instance.currentUser?.displayName ??
        'Nurse';

    return StreamBuilder<int>(
      stream: messagesService.totalUnreadMessagesStream(),
      builder: (context, snap) {
        final unreadMessages = snap.data ?? 0;
        return Scaffold(
          backgroundColor: NurseColors.pageBg,
          body: Directionality(
            textDirection: ui.TextDirection.ltr,
            child: ResponsiveDashboardShell(
              sidebarWidth: 260,
              minMainWidth: 640,
              sidebar: NurseSidebar(
                currentPage: _page == NursePage.contactDoctor
                    ? NursePage.emergency
                    : _page,
                nurseName: name,
                openEmergencyCount: emergencyVm.open.length,
                notificationBadge: _notifBadge(),
                unreadMessages: unreadMessages,
                onPageChanged: (p) {
                  setState(() {
                    _vitalsPatientId = null;
                    _detailsPatientId = null;
                    _page = p;
                  });
                },
                onLogout: _logout,
              ),
              main: Column(
                children: [
                  NurseTopBar(
                    title: _title(_page),
                    nurseName: name,
                    onSearchChanged: (s) => setState(() => _topSearch = s),
                  ),
                  Expanded(
                    child: Container(
                      color: NurseColors.pageBg,
                      child: _buildBody(),
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

  Widget _buildBody() {
    if (_vitalsPatientId != null) {
      return PatientMonitoringScreen(
        patientId: _vitalsPatientId!,
        onBack: () => setState(() => _vitalsPatientId = null),
      );
    }
    if (_detailsPatientId != null) {
      return PatientDetailsScreen(
        patientId: _detailsPatientId!,
        onBack: () => setState(() => _detailsPatientId = null),
        onMonitor: () => setState(() {
          _vitalsPatientId = _detailsPatientId;
          _detailsPatientId = null;
        }),
      );
    }

    switch (_page) {
      case NursePage.dashboard:
        return _DashboardTab(
          searchQuery: _topSearch,
          onViewAllAlerts: () =>
              setState(() => _page = NursePage.emergency),
        );
      case NursePage.patients:
        return PatientsListScreen(
          onOpenMonitoring: (id) => setState(() => _vitalsPatientId = id),
          onOpenDetails: (id) => setState(() => _detailsPatientId = id),
        );
      case NursePage.vitals:
        return _VitalsPickerTab(
          onOpen: (id) => setState(() => _vitalsPatientId = id),
        );
      case NursePage.medications:
        return const MedicationsScreen();
      case NursePage.emergency:
        return EmergencyRequestsScreen(
          onContactDoctor: (pid, pname) {
            setState(() {
              _contactPatientId = pid;
              _contactPatientName = pname;
              _page = NursePage.contactDoctor;
            });
          },
        );
      case NursePage.rooms:
        return const RoomsScreen();
      case NursePage.appointments:
        return const NurseAppointmentsScreen();
      case NursePage.messages:
        return const NurseMessagesScreen();
      case NursePage.notifications:
        return const NurseNotificationsScreen();
      case NursePage.reports:
        return const NurseReportsScreen();
      case NursePage.settings:
        return const NurseSettingsScreen();
      case NursePage.icu:
        return const IntensiveCareScreen();
      case NursePage.contactDoctor:
        return Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _page = NursePage.emergency;
                  _contactPatientId = null;
                  _contactPatientName = null;
                }),
              ),
            ),
            Expanded(
              child: ContactDoctorScreen(
                patientContext: _contactPatientId,
                patientName: _contactPatientName,
              ),
            ),
          ],
        );
    }
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    this.searchQuery = '',
    required this.onViewAllAlerts,
  });

  final String searchQuery;
  final VoidCallback onViewAllAlerts;

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<NurseDashboardViewModel>();
    final patientsVm = context.watch<NursePatientsViewModel>();

    if (dash.loading && dash.counts == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final c = dash.counts ?? {};
    final alerts = dash.recentAlerts;
    final q = searchQuery.trim().toLowerCase();
    final filteredAlerts = q.isEmpty
        ? alerts
        : alerts
            .where((a) =>
                a.patientName.toLowerCase().contains(q) ||
                (a.reason ?? '').toLowerCase().contains(q))
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NursePageHeader(
            title: NurseStrings.pageDashboard,
            subtitle: NurseStrings.portalSubtitle,
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final cols = w > 1100 ? 4 : (w > 720 ? 2 : 1);
              double cellW() =>
                  cols == 1 ? w : (w - (cols - 1) * 16) / cols;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: cellW(),
                    child: PatientStatusCard(
                      title: NurseStrings.statTotalPatients,
                      value: '${c['patients'] ?? 0}',
                      icon: Icons.groups_2_outlined,
                      accentColor: NurseColors.accentBlue,
                    ),
                  ),
                  SizedBox(
                    width: cellW(),
                    child: PatientStatusCard(
                      title: NurseStrings.statCritical,
                      value: '${c['critical'] ?? 0}',
                      icon: Icons.emergency_outlined,
                      accentColor: NurseColors.critical,
                    ),
                  ),
                  SizedBox(
                    width: cellW(),
                    child: PatientStatusCard(
                      title: NurseStrings.statIcu,
                      value: '${c['icu'] ?? 0}',
                      icon: Icons.local_hospital_outlined,
                      accentColor: NurseColors.primaryDark,
                    ),
                  ),
                  SizedBox(
                    width: cellW(),
                    child: PatientStatusCard(
                      title: NurseStrings.statBirths,
                      value: '${c['birthsToday'] ?? 0}',
                      icon: Icons.child_care_outlined,
                      accentColor: NurseColors.success,
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
                child: NurseSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              NurseStrings.recentAlerts,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: onViewAllAlerts,
                            child: Text(NurseStrings.viewAllAlerts),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (filteredAlerts.isEmpty)
                        Text(
                          NurseStrings.noAlerts,
                          style: GoogleFonts.inter(
                            color: NurseColors.textSecondary,
                          ),
                        )
                      else
                        ...filteredAlerts.map((a) => _alertTile(a)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: NurseSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        NurseStrings.vitalsOverview,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        patientsVm.allPatients.isEmpty
                            ? NurseStrings.noPatients
                            : '${NurseStrings.statTotalPatients}: ${patientsVm.allPatients.length}',
                        style: GoogleFonts.inter(
                          color: NurseColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        NurseStrings.patientsByStatus,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _statusBar(
                        context,
                        patientsVm,
                        'stable',
                        NurseColors.success,
                      ),
                      _statusBar(
                        context,
                        patientsVm,
                        'critical',
                        NurseColors.critical,
                      ),
                      _statusBar(
                        context,
                        patientsVm,
                        'active',
                        NurseColors.accentBlue,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _alertTile(EmergencyRequestModel a) {
    final sev = a.severity.toLowerCase();
    final high = sev == 'high';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: NurseColors.tint,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          title: Text(
            a.patientName,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(a.reason ?? ''),
          trailing: Chip(
            label: Text(
              high ? NurseStrings.priorityHigh : NurseStrings.priorityMedium,
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800),
            ),
            backgroundColor: high
                ? NurseColors.critical.withValues(alpha: 0.15)
                : NurseColors.warning.withValues(alpha: 0.15),
          ),
        ),
      ),
    );
  }

  Widget _statusBar(
    BuildContext context,
    NursePatientsViewModel vm,
    String status,
    Color color,
  ) {
    final n = vm.allPatients
        .where((p) => p.status.toLowerCase() == status)
        .length;
    final total = vm.allPatients.isEmpty ? 1 : vm.allPatients.length;
    final pct = (n / total).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$status ($n)',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: NurseColors.cardBorder,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalsPickerTab extends StatelessWidget {
  const _VitalsPickerTab({required this.onOpen});

  final void Function(String patientId) onOpen;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NursePatientsViewModel>();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NursePageHeader(
            title: NurseStrings.pageVitals,
            subtitle: NurseStrings.selectPatient,
          ),
          const SizedBox(height: 16),
          if (vm.filtered.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  NurseStrings.noPatients,
                  style: GoogleFonts.inter(color: NurseColors.textSecondary),
                ),
              ),
            )
          else
            Expanded(
              child: NurseSurfaceCard(
                child: ListView.separated(
                  itemCount: vm.filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = vm.filtered[i];
                    return ListTile(
                      title: Text(p.fullName),
                      subtitle: Text('${NurseStrings.colRoom}: ${p.roomNumber ?? '—'}'),
                      trailing: FilledButton(
                        onPressed: () => onOpen(p.id),
                        style: FilledButton.styleFrom(
                          backgroundColor: NurseColors.primary,
                        ),
                        child: Text(NurseStrings.updateVitals),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
